import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class CreateDocumentUseCase {
  final DocumentRepository repository;

  CreateDocumentUseCase(this.repository);

  Future<Document> call(Document document) async {
    return repository.createDocument(document);
  }
}