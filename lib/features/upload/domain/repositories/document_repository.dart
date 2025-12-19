import 'package:myfin/features/upload/domain/entities/document.dart';

enum SortDirection { ascending, descending }

enum DocumentSortField { updatedAt, createdAt, postingDate, name }

abstract class DocumentRepository {
  // create new doc in datasource, return the new doc obj
  Future<Document> createDocument(Document document);

  // return doc obj by id
  Future<Document> getDocumentById(String id);

  // get a list of docs, choose whether to filter by status and type
  // supports pagination using page and limit
  Future<List<Document>> getDocuments({
    String? status,
    String? type,
    String memberId,
    DocumentSortField sortBy = DocumentSortField.updatedAt,
    SortDirection direction = SortDirection.descending,
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  });

  // return list of docs created by a specified username/user_id
  Future<List<Document>> getDocumentsByCreator(String memberId);

  // update existing doc
  Future<Document> updateDocument(Document document);

  Future<Document> updateDocumentStatus(String id, String newStatus);

  Future<void> deleteDocument(String id);

  // filter documents by main category (aggregated from line items)
  Future<List<Document>> getDocumentsByMainCategory({
    required String memberId,
    required String mainCategory,
    required String transactionType, // 'income' or 'expense'
    required DateTime startDate,
    required DateTime endDate,
    DocumentSortField sortBy = DocumentSortField.postingDate,
    SortDirection direction = SortDirection.descending,
    int page = 1,
    int limit = 50,
  });
}
