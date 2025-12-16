import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_history_state.dart';

class UploadHistoryCubit extends Cubit<UploadHistoryState> {
  final DocumentRepository _repository;

  UploadHistoryCubit(this._repository) : super(UploadHistoryInitial());

  Future<void> fetchHistory() async {
    try {
      emit(UploadHistoryLoading());
      
      // Fetch a larger number of docs (e.g., 50) or implement pagination later
      final documents = await _repository.getDocuments(
        limit: 50, 
        // Assuming your Repo supports sorting, sort by newest first
        sortBy: DocumentSortField.updatedAt, 
        direction: SortDirection.descending
      );
      
      emit(UploadHistoryLoaded(documents));
    } catch (e) {
      emit(UploadHistoryError("Failed to load history: $e"));
    }
  }
}