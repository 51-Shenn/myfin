import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_history_state.dart';

class UploadHistoryCubit extends Cubit<UploadHistoryState> {
  final DocumentRepository _repository;

  UploadHistoryCubit(this._repository) : super(UploadHistoryInitial());

  Future<void> fetchHistory() async {
    try {
      emit(UploadHistoryLoading());
      
      final user = FirebaseAuth.instance.currentUser;
      final String currentMemberId = user?.uid ?? "";
      
      final documents = await _repository.getDocuments(
        memberId: currentMemberId,
        sortBy: DocumentSortField.updatedAt, 
        direction: SortDirection.descending
      );
      
      emit(UploadHistoryLoaded(documents));
    } catch (e) {
      emit(UploadHistoryError("Failed to load history: $e"));
    }
  }
}