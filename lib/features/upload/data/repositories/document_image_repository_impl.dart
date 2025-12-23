import 'package:myfin/features/upload/data/datasources/document_image_data_source.dart';
import 'package:myfin/features/upload/domain/repositories/document_image_repository.dart';

class DocumentImageRepositoryImpl implements DocumentImageRepository {
  final DocumentImageDataSource dataSource;

  DocumentImageRepositoryImpl(this.dataSource);

  @override
  Future<void> saveImage(String documentId, String imageBase64) async {
    await dataSource.saveImage(documentId, imageBase64);
  }

  @override
  Future<String?> getImage(String documentId) async {
    return await dataSource.getImage(documentId);
  }

  @override
  Future<void> deleteImage(String documentId) async {
    await dataSource.deleteImage(documentId);
  }
}
