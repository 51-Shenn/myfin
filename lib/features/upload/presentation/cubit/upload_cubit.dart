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
  final ProfileRepository profileRepository; // Add dependency
  final ImagePicker _picker = ImagePicker();
  final GeminiOCRDataSource _ocrDataSource = GeminiOCRDataSource();

  UploadCubit({required this.getRecentDocumentsUseCase, required this.profileRepository,})
    : super(const UploadInitial());

  // ... (Keep existing fetchDocument, recentUploadedDocClicked, viewAllClicked, manualKeyInSelected) ...
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

  // --- Image/File Selection Handlers ---

  Future<void> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
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
        imageQuality: 80,
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
        ], // Allowed Extensions
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

  // --- Main Processing Logic ---

  Future<void> _processFile(String path, String type) async {
    try {
      emit(UploadLoading(state.document));

      // 1. Fetch User Business Profile
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

      // 2. Pass companyName to OCR methods
      if (type == 'pdf') {
        jsonResult = await _ocrDataSource.extractDataFromMedia(
          path,
          'application/pdf',
          companyName,
        );
      } else if (type == 'xlsx') {
        final String csvData = await _convertExcelToCsvString(path);
        jsonResult = await _ocrDataSource.extractDataFromText(csvData, companyName);
      } else {
        jsonResult = await _ocrDataSource.extractDataFromMedia(
          path,
          'image/jpeg',
          companyName,
        );
      }

      await _mapJsonToStateAndNavigate(jsonResult, path, type);
    } catch (e) {
      if (isClosed) return;
      emit(UploadError(state.document, 'Processing Failed: $e'));
      emit(UploadLoaded(state.document));
    }
  }

  // Helper to read Excel and flatten it to text for the AI
  Future<String> _convertExcelToCsvString(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw Exception("File not found at path: $path");
    }

    final Uint8List bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception("The selected file is empty.");
    }

    // Attempt 1: Try using 'excel' package
    try {
      final excel = Excel.decodeBytes(bytes);
      final buffer = StringBuffer();

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;

        buffer.writeln("Sheet: $table");

        for (var row in sheet.rows) {
          final rowString = row
              .map((cell) {
                if (cell == null || cell.value == null) return "";

                final val = cell.value;
                // Checks for Excel 4.0.0+
                if (val is TextCellValue) return val.value.toString();
                if (val is DoubleCellValue) return val.value.toString();
                if (val is IntCellValue) return val.value.toString();
                if (val is BoolCellValue) return val.value.toString();
                if (val is DateCellValue)
                  return val.asDateTimeLocal().toIso8601String();
                if (val is TimeCellValue) return val.toString();
                if (val is FormulaCellValue) return val.formula.toString();

                return val.toString();
              })
              .join(", ");

          if (rowString.trim().replaceAll(',', '').isNotEmpty) {
            buffer.writeln(rowString);
          }
        }
        buffer.writeln("---");
      }

      if (buffer.isNotEmpty) return buffer.toString();
    } catch (e) {
      print("Primary Excel decoder failed: $e. Attempting fallback...");
    }

    // Attempt 2: Try using 'spreadsheet_decoder' package as fallback
    try {
      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      final buffer = StringBuffer();

      for (var table in decoder.tables.keys) {
        final sheet = decoder.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;

        buffer.writeln("Sheet: $table");
        for (var row in sheet.rows) {
          final rowString = row
              .map((cell) => cell?.toString() ?? "")
              .join(", ");
          if (rowString.trim().replaceAll(',', '').isNotEmpty) {
            buffer.writeln(rowString);
          }
        }
        buffer.writeln("---");
      }

      if (buffer.isNotEmpty) return buffer.toString();
    } catch (e) {
      print("Fallback Excel decoder failed: $e");
    }

    throw Exception(
      "Failed to process Excel file. The file might be corrupted, password protected, or in an unsupported format.",
    );
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
    
    // Parse Document Date
    final DateTime postingDate = DateTime.tryParse(docData['date'] ?? '') ?? DateTime.now();

    // --- DUE DATE LOGIC ---
    DateTime? parsedDueDate = DateTime.tryParse(docData['due_date'] ?? '');
    String finalDueDateString;
    
    if (parsedDueDate != null) {
      finalDueDateString = parsedDueDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
    } else {
      // Default to 30 days if null
      finalDueDateString = postingDate.add(const Duration(days: 30)).toIso8601String().split('T')[0];
    }

    // Process Metadata
    List<AdditionalInfoRow> metadataList = (jsonResult['metadata'] as List?)
          ?.map(
            (m) => AdditionalInfoRow(
              id: const Uuid().v4(),
              key: m['key'] ?? '',
              value: m['value']?.toString() ?? '',
            ),
          )
          .toList() ?? [];

    // Check if Due Date already exists in metadata (from AI), if not, add it
    bool hasDueDate = metadataList.any((row) => row.key.toLowerCase().contains('due date'));
    if (!hasDueDate) {
      metadataList.add(AdditionalInfoRow(
        id: const Uuid().v4(),
        key: 'Due Date',
        value: finalDueDateString,
      ));
    }

    final document = Document(
      id: '', 
      memberId: currentMemberId,
      name: docData['name'] ?? 'Uploaded Document',
      type: docData['type'] ?? 'Invoice',
      status: 'Draft',
      createdBy: 'AI OCR',
      postingDate: postingDate,
      imageBase64: imageBase64,
      metadata: metadataList, // Updated metadata with Due Date
    );

    // ... (Rest of line item creation logic remains the same)
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

    // Navigate
    if (isClosed) return;
    emit(UploadNavigateToDocDetails(document, extractedLineItems: lineItems));
    emit(UploadLoaded(state.document));
  }


  Future<String?> _generateThumbnail(String filePath, String type) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    try {
      // HANDLE PDF: Rasterize the first page
      if (type == 'pdf' || type == 'application/pdf') {
        final pdfBytes = await file.readAsBytes();
        // raster() returns a stream of pages. We take the first one.
        // dpi: 72 is usually enough for a screen thumbnail
        await for (var page in Printing.raster(pdfBytes, pages: [0], dpi: 72)) {
          final pngBytes = await page.toPng();
          return base64Encode(pngBytes);
        }
      }
      // HANDLE IMAGES: Standard read
      else if (['jpg', 'jpeg', 'png', 'image'].contains(type.toLowerCase())) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }

      // HANDLE EXCEL:
      // We return null here.
      // In the UI, we will check if imageBase64 is null and show an Icon instead.
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}
