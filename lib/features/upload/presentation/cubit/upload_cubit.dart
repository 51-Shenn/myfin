import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/usecases/get_recent_doc_use_case.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/data/datasources/gemini_ocr_data_source.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';

class UploadCubit extends Cubit<UploadState> {
  final GetRecentDocumentsUseCase getRecentDocumentsUseCase;
  final ProfileRepository profileRepository;
  final ImagePicker _picker = ImagePicker();
  final GeminiOCRDataSource _ocrDataSource = GeminiOCRDataSource();

  UploadCubit({
    required this.getRecentDocumentsUseCase,
    required this.profileRepository,
  }) : super(const UploadInitial());

  Future<void> fetchDocument() async {
    try {
      emit(UploadLoading(state.document));
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(UploadError(state.document, 'User not authenticated'));
        return;
      }
      final documents = await getRecentDocumentsUseCase(
        limit: 3,
        memberId: user.uid,
      );
      if (isClosed) return;
      emit(UploadLoaded(documents));
    } catch (e) {
      if (isClosed) return;
      emit(UploadError(state.document, 'Failed to load documents: $e'));
    }
  }

  void recentUploadedDocClicked(Document doc) {
    emit(UploadNavigateToDocDetails(doc, extractedLineItems: null));
    emit(UploadLoaded(state.document));
  }

  void viewAllClicked() {
    emit(UploadNavigateToHistory(state.document));
    emit(UploadLoaded(state.document));
  }

  void manualKeyInSelected() {
    emit(const UploadNavigateToManual([]));
    fetchDocument();
  }

  Future<void> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 30,
      );

      if (image != null) {
        await _processFile(image.path, 'image');
      }
    } catch (e) {
      emit(UploadError(state.document, 'Failed to open gallery: $e'));
    }
  }

  Future<void> scanUsingCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 50,
      );

      if (photo != null) {
        await _processFile(photo.path, 'image');
      }
    } catch (e) {
      emit(UploadError(state.document, 'Camera error: $e'));
    }
  }

  Future<void> fileUploadSelected() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'png',
          'jpeg',
          'pdf',
          'xlsx',
        ],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String ext = result.files.single.extension?.toLowerCase() ?? '';

        await _processFile(path, ext);
      }
    } catch (e) {
      emit(UploadError(state.document, 'File pick error: $e'));
    }
  }

  Future<void> _processFile(String path, String type) async {
    try {
      emit(UploadLoading(state.document));

      final user = FirebaseAuth.instance.currentUser;
      String? companyName;
      if (user != null) {
        try {
          final profile = await profileRepository.getBusinessProfile(user.uid);
          if (profile.name.isNotEmpty) {
            companyName = profile.name;
          }
        } catch (e) {
          print("Could not load business profile for OCR context: $e");
        }
      }

      Map<String, dynamic> jsonResult;

      print("[DEBUG] Processing file type: $type at $path");

      if (type == 'pdf') {
        jsonResult = await _ocrDataSource.extractDataFromMedia(
          path,
          'application/pdf',
          companyName,
        );
      } else if (type == 'xlsx') {
        final String csvData = await _convertExcelToCsvString(path);
        
        if (csvData.isEmpty) {
           throw Exception("Could not extract any text from the Excel file.");
        }

        print("[DEBUG] Sending CSV data length: ${csvData.length}");
        
        jsonResult = await _ocrDataSource.extractDataFromText(
          csvData,
          companyName,
        );
      } else {
        jsonResult = await _ocrDataSource.extractDataFromMedia(
          path,
          'image/jpeg',
          companyName,
        );
      }

      await _mapJsonToStateAndNavigate(jsonResult, path, type);
    } catch (e) {
      print("[DEBUG] Processing Error: $e");
      if (isClosed) return;
      emit(UploadError(state.document, 'Processing Failed: $e'));
      emit(UploadLoaded(state.document));
    }
  }

  // Helper function to read excel with debug logging
  Future<String> _convertExcelToCsvString(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw Exception("File not found at path: $path");
    }

    final Uint8List bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception("The selected file is empty.");
    }

    String? extractedText;

    // STRATEGY 1: SpreadsheetDecoder
    try {
      print("[DEBUG] Attempting Strategy 1: SpreadsheetDecoder");
      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      final buffer = StringBuffer();
      
      for (var table in decoder.tables.keys) {
        final sheet = decoder.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;

        print("[DEBUG] Reading Sheet: $table");

        for (var row in sheet.rows) {
          // Convert row to string, handle nulls
          final List<String> rowValues = row.map((cell) {
             if (cell == null) return "";
             return cell.toString().trim();
          }).toList();

          final rowString = rowValues.join(", ");
          
          // Debug first few rows
          if (buffer.length < 500) print("[DEBUG] Row: $rowString");

          if (rowString.replaceAll(',', '').trim().isNotEmpty) {
            buffer.writeln(rowString);
          }
        }
      }
      extractedText = buffer.toString();
    } catch (e) {
      print("[DEBUG] Strategy 1 failed: $e");
    }

    // STRATEGY 2: Excel Package (Fallback if Strategy 1 failed OR returned empty)
    if (extractedText == null || extractedText.trim().isEmpty) {
       print("[DEBUG] Strategy 1 extracted extracted nothing. Attempting Strategy 2: Excel Package");
       try {
        final excel = Excel.decodeBytes(bytes);
        final buffer = StringBuffer();

        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table];
          if (sheet == null || sheet.maxRows == 0) continue;

          for (var row in sheet.rows) {
            final rowString = row.map((cell) {
              if (cell == null || cell.value == null) return "";
              
              final val = cell.value;
              // Handle various cell types specifically for string conversion
              if (val is TextCellValue) return val.value;
              if (val is DoubleCellValue) return val.value.toString();
              if (val is IntCellValue) return val.value.toString();
              if (val is DateCellValue) {
                return val.asDateTimeLocal().toIso8601String().split('T')[0];
              }
              return val.toString();
            }).join(", ");

            if (rowString.replaceAll(',', '').trim().isNotEmpty) {
               buffer.writeln(rowString);
            }
          }
        }
        extractedText = buffer.toString();
      } catch (e) {
        print("[DEBUG] Strategy 2 failed: $e");
      }
    }

    if (extractedText != null && extractedText.isNotEmpty) {
      print("[DEBUG] Final Extracted Text (First 100 chars): ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}");
      return extractedText;
    }

    throw Exception("Failed to extract text from Excel. The file might be corrupted, password protected, or empty.");
  }

  Future<void> _mapJsonToStateAndNavigate(
    Map<String, dynamic> jsonResult,
    String filePath,
    String type,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final String currentMemberId = user?.uid ?? "";

    String? imageBase64 = await _generateThumbnail(filePath, type);

    final docData = jsonResult['document'];

    final DateTime postingDate =
        DateTime.tryParse(docData['date'] ?? '') ?? DateTime.now();

    DateTime? parsedDueDate = DateTime.tryParse(docData['due_date'] ?? '');
    String finalDueDateString;

    if (parsedDueDate != null) {
      finalDueDateString = parsedDueDate.toIso8601String().split('T')[0];
    } else {
      finalDueDateString = postingDate
          .add(const Duration(days: 30))
          .toIso8601String()
          .split('T')[0];
    }

    List<AdditionalInfoRow> metadataList =
        (jsonResult['metadata'] as List?)
            ?.map(
              (m) => AdditionalInfoRow(
                id: const Uuid().v4(),
                key: m['key'] ?? '',
                value: m['value']?.toString() ?? '',
              ),
            )
            .toList() ??
        [];

    bool hasDueDate = metadataList.any(
      (row) => row.key.toLowerCase().contains('due date'),
    );
    if (!hasDueDate) {
      metadataList.add(
        AdditionalInfoRow(
          id: const Uuid().v4(),
          key: 'Due Date',
          value: finalDueDateString,
        ),
      );
    }

    final document = Document(
      id: '',
      memberId: currentMemberId,
      name: docData['name'] ?? 'Uploaded Document',
      type: docData['type'] ?? 'Invoice',
      status: 'Draft',
      createdBy: 'AI OCR',
      postingDate: postingDate,
      metadata: metadataList,
    );

    final List<dynamic> linesData = jsonResult['line_items'] ?? [];
    final List<DocumentLineItem> lineItems = [];

    for (int i = 0; i < linesData.length; i++) {
      final item = linesData[i];
      lineItems.add(
        DocumentLineItem(
          lineItemId: 'TEMP_${const Uuid().v4()}',
          documentId: '',
          lineNo: i + 1,
          lineDate: document.postingDate,
          categoryCode: item['category'] ?? '',
          description: item['description'] ?? '',
          total: (item['amount'] as num?)?.toDouble() ?? 0.0,
          debit: 0,
          credit: 0,
          attribute: [],
        ),
      );
    }

    if (isClosed) return;
    emit(
      UploadNavigateToDocDetails(
        document,
        extractedLineItems: lineItems,
        imageBase64: imageBase64,
      ),
    );
    emit(UploadLoaded(state.document));
  }

  Future<String?> _generateThumbnail(String filePath, String type) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    try {
      // Excel files do not have a thumbnail usually, return null
      if (type == 'xlsx' || type.contains('sheet')) {
        return null; 
      }

      if (type == 'pdf' || type == 'application/pdf') {
        final pdfBytes = await file.readAsBytes();
        await for (var page in Printing.raster(pdfBytes, pages: [0], dpi: 72)) {
          final pngBytes = await page.toPng();
          return base64Encode(pngBytes);
        }
      } else if (['jpg', 'jpeg', 'png', 'image'].contains(type.toLowerCase())) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }

      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}