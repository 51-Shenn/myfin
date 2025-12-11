import 'package:flutter_bloc/flutter_bloc.dart';
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
    
  }

  void fileUploadSelected() {

  }

  void selectFromGallery() {

  }

  void scanUsingCamera() {
    
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