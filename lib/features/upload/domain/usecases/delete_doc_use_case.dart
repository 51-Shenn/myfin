import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class DeleteDocumentUseCase {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  Future<void> call(String id) async {
    return repository.deleteDocument(id);
  }
}