import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class GetRecentDocumentsUseCase {
  final DocumentRepository repository;

  GetRecentDocumentsUseCase(this.repository);

  Future<List<Document>> call({int limit = 3, required String memberId}) async {
    return repository.getDocuments(
      limit: limit,
      memberId: memberId,
      sortBy: DocumentSortField.updatedAt,
      direction: SortDirection.descending,
    );
  }
}