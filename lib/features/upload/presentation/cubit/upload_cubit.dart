import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_state.dart';
import 'package:file_picker/file_picker.dart';

class UploadCubit extends Cubit<UploadState> {
  UploadCubit() : super(UploadInitial());

  Future<void> fetchDocument() async {
    try {
      // current state is loading
      emit(UploadLoading(state.document));

      // show loading indicator (stimulate database call)
      await Future<void>.delayed(const Duration(seconds: 1));

      // retrive data
      final List<Document> data = [
        Document(
          id: 'DOC001',
          name: 'Invoice #1001',
          type: 'Invoice',
          status: 'Draft',
          createdBy: 'Admin',
          updatedAt: DateTime.now(),
          postingDate: DateTime(2025, 1, 10),
          memberId: ''
        ),
        Document(
          id: 'DOC002',
          name: 'Receipt #900',
          type: 'Receipt',
          status: 'Posted',
          createdBy: 'System',
          createdAt: DateTime(2025, 2, 1),
          updatedAt: DateTime.now(),
          postingDate: DateTime(2025, 2, 5),
          memberId: ''
        ),
        Document(
          id: 'DOC003',
          name: 'Delivery Order',
          type: 'DO',
          status: 'Completed',
          createdBy: 'Manager',
          updatedAt: DateTime.now(),
          postingDate: DateTime(2025, 3, 20),
          metadata: [
            {"weight": 120},
            {"truckNo": "AB1234"},
          ],
          memberId: ''
        ),
      ];

      // if got data, tell state that currently is not loading
      emit(UploadLoaded(data));

    } catch (e) {
      // emit error state if something goes wrong
      emit(UploadError(state.document, 'Failed to load documents'));
    }
  }

  void manualKeyInSelected() {
    // emit nav state
    emit(UploadNavigateToManual(state.document));

    // if user nav back reset state
    emit(UploadLoaded(state.document));
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
        emit(UploadLoaded(state.document));
      } 
    } catch (e) {
      emit(UploadError(state.document, 'File pick error: $e'));
    }
  }

  // helper
  final ImagePicker _picker = ImagePicker();
  Future<void> selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        emit(UploadImagePicked(state.document, image.path));
        emit(UploadLoaded(state.document));
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
        emit(UploadLoaded(state.document));
      }
    } catch (e) {
      emit(UploadError(state.document, 'Camera error: $e'));
    }
    
  }

  void recentUploadedDocClicked(Document document) {
    // nav to doc_details with id (doc_id)
  }

  void forceLoading() {
    emit(UploadLoading(state.document));
    
    // Auto return to loaded state after 3 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (!isClosed) {
        emit(UploadLoaded(state.document));
      }
    });
  }
}