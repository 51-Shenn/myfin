import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class GetDocumentsByCreatorUseCase {
  final DocumentRepository repository;

  GetDocumentsByCreatorUseCase(this.repository);

  Future<List<Document>> call(String memberId) async {
    return repository.getDocumentsByCreator(memberId);
  }
}