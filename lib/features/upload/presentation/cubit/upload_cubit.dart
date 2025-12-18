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

class UploadCubit extends Cubit<UploadState> {
  final GetRecentDocumentsUseCase getRecentDocumentsUseCase;
  final ImagePicker _picker = ImagePicker();
  final GeminiOCRDataSource _ocrDataSource = GeminiOCRDataSource();

  UploadCubit({required this.getRecentDocumentsUseCase})
    : super(const UploadInitial());

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

      emit(UploadLoaded(documents));
    } catch (e) {
      emit(UploadError(state.document, 'Failed to load documents: $e'));
    }
  }

  void recentUploadedDocClicked(Document doc) {
    // Navigate to details with existing document and let DocDetailCubit fetch line items
    emit(UploadNavigateToDocDetails(doc, extractedLineItems: null));
    // Reset state to avoid repeated navigation
    emit(UploadLoaded(state.document));
  }

  void viewAllClicked() {
    emit(UploadNavigateToHistory(state.document));
    emit(UploadLoaded(state.document));
  }

  void manualKeyInSelected() {
    emit(const UploadNavigateToManual([]));
    fetchDocument(); // Reload list
  }

  // --- Image/File Selection Handlers ---

  Future<void> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Emit image picked state first (optional)
        // emit(UploadImagePicked(state.document, image.path));
        // Process immediately
        await processPickedImage(image.path);
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
        emit(UploadImagePicked(state.document, photo.path));
        await processPickedImage(photo.path);
      }
    } catch (e) {
      emit(UploadError(state.document, 'Camera error: $e'));
    }
  }

  Future<void> fileUploadSelected() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'], // Restrict to images for OCR for now
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String name = result.files.single.name;

        emit(UploadFilePicked(state.document, path, name));
        await processPickedImage(path);
      }
    } catch (e) {
      emit(UploadError(state.document, 'File pick error: $e'));
    }
  }

  // --- AI Processing Logic ---

  Future<void> processPickedImage(String imagePath) async {
    try {
      // Show loading while AI processes
      emit(UploadLoading(state.document));

      final user = FirebaseAuth.instance.currentUser;
      final String currentMemberId = user?.uid ?? "";

      final jsonResult = await _ocrDataSource.extractDataFromImage(imagePath);

      // convert image to base64
      String? imageBase64;
      try {
        final imageFile = File(imagePath);
        final bytes = await imageFile.readAsBytes();
        imageBase64 = base64Encode(bytes);
      } catch (e) {
        print('Failed to encode image to base64: $e');
      }

      final docData = jsonResult['document'];
      final document = Document(
        id: '', // empty ID = New Document
        memberId: currentMemberId,
        name: docData['name'] ?? 'Scanned Document',
        type: docData['type'] ?? 'Invoice',
        status: 'Draft',
        createdBy: 'AI OCR',
        postingDate: DateTime.tryParse(docData['date'] ?? '') ?? DateTime.now(),
        imageBase64: imageBase64,
        metadata: (jsonResult['metadata'] as List?)
            ?.map(
              (m) => AdditionalInfoRow(
                id: const Uuid().v4(),
                key: m['key'] ?? '',
                value: m['value']?.toString() ?? '',
              ),
            )
            .toList(),
      );

      final List<dynamic> linesData = jsonResult['line_items'] ?? [];
      final List<DocumentLineItem> lineItems = [];

      for (int i = 0; i < linesData.length; i++) {
        final item = linesData[i];
        lineItems.add(
          DocumentLineItem(
            lineItemId: 'TEMP_${const Uuid().v4()}', // Temp ID
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

      // 4. Navigate to Details Screen with Pre-filled Data
      emit(UploadNavigateToDocDetails(document, extractedLineItems: lineItems));

      // 5. Reset state slightly so back button works
      emit(UploadLoaded(state.document));
    } catch (e) {
      emit(UploadError(state.document, 'AI Processing Failed: $e'));
    }
  }

  // Placeholder if you add non-image file processing later
  Future<void> processPickedFile(String path, String fileName) async {
    // For now, redirect to image processing if it's an image
    if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      await processPickedImage(path);
    } else {
      emit(UploadError(state.document, "Only image files are supported for AI OCR currently."));
    }
  }
}