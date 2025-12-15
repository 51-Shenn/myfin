import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

abstract class DocumentDataSource {
  Future<String> createDocument(Map<String, dynamic> documentData);
  Future<Map<String, dynamic>?> getDocument(String id);
  
  Future<List<Map<String, dynamic>>> getDocuments({
    Map<String, dynamic>? filters,
    DocumentSortField? orderByField,
    SortDirection direction = SortDirection.descending,
    int? limit,
    int? page,
  });

  Future<void> updateDocument(String id, Map<String, dynamic> updateData);
  Future<void> deleteDocument(String id);
}