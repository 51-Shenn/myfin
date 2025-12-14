import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class UpdateDocumentUseCase {
  final DocumentRepository repository;

  UpdateDocumentUseCase(this.repository);

  Future<Document> call(Document document) async {
    return repository.updateDocument(document);
  }
}