import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/usecases/get_recent_doc_use_case.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_state.dart';
import 'package:file_picker/file_picker.dart';

class UploadCubit extends Cubit<UploadState> {
  final GetRecentDocumentsUseCase getRecentDocumentsUseCase;
  final ImagePicker _picker = ImagePicker();

  UploadCubit({
    required this.getRecentDocumentsUseCase,
  }) : super(UploadInitial());

  Future<void> fetchDocument() async {
    try {
      emit(UploadLoading(state.document));

      // Use the use case to get documents
      final documents = await getRecentDocumentsUseCase(limit: 3);

      emit(UploadLoaded(documents));
    } catch (e) {
      emit(UploadError(state.document, 'Failed to load documents: $e'));
    }
  }

  void recentUploadedDocClicked(Document doc) {
    final currentDocuments = state.document;

    emit(UploadNavigateToDocDetails(doc));

    emit(UploadLoaded(currentDocuments));
  }

  void manualKeyInSelected() {
    final currentDocs = state.document;
    emit(UploadNavigateToManual(currentDocs));
    // Reset state to Loaded so the UI shows the list, not the spinner
    emit(UploadLoaded(currentDocs)); 
  }

  Future<void> fileUploadSelected() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String name = result.files.single.name;

        emit(UploadFilePicked(state.document, path, name));
        // Don't emit UploadLoaded here as we might want to process the file
      }
    } catch (e) {
      emit(UploadError(state.document, 'File pick error: $e'));
    }
  }

  Future<void> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        emit(UploadImagePicked(state.document, image.path));
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
      );

      if (photo != null) {
        emit(UploadImagePicked(state.document, photo.path));
      }
    } catch (e) {
      emit(UploadError(state.document, 'Camera error: $e'));
    }
  }

  void forceLoading() {
    emit(UploadLoading(state.document));

    Future.delayed(Duration(seconds: 2), () {
      if (!isClosed) {
        fetchDocument();
      }
    });
  }

  // Add method to process picked image/file
  Future<void> processPickedFile(String path, String fileName) async {
    // TODO: Implement file processing logic
    print('Processing file: $fileName at $path');
  }

  Future<void> processPickedImage(String imagePath) async {
    // TODO: Implement image processing logic
    print('Processing image: $imagePath');
  }
}