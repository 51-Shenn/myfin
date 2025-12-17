import 'package:myfin/features/upload/data/datasources/document_data_source.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentDataSource dataSource;

  DocumentRepositoryImpl(this.dataSource);

  // --- Create ---
  @override
  Future<Document> createDocument(Document document) async {
    // 1. Map Document entity to raw data
    final rawData = document.toMap();

    // 2. Call Data Source to create the document
    final docId = await dataSource.createDocument(rawData);

    // 3. For the return, get the fresh data from the datasource (or simulate)
    // For simplicity, we create a copy of the original doc with the new ID
    return Document(
      id: docId,
      name: document.name,
      // ... copy all fields from the input document, ensuring timestamps are correct
      type: document.type,
      status: document.status,
      createdBy: document.createdBy,
      createdAt: DateTime.now(), // Since it was just created
      updatedAt: DateTime.now(), // Since it was just created
      postingDate: document.postingDate,
      metadata: document.metadata,
      refDocType: document.refDocType,
      refDocId: document.refDocId,
      memberId: document.memberId
    );
  }

  // --- Read (Single) ---
  @override
  Future<Document> getDocumentById(String id) async {
    // 1. Call Data Source to get raw data
    final rawData = await dataSource.getDocument(id);

    // 2. Handle null case
    if (rawData == null) {
      throw Exception('Document with ID $id not found.'); // Use a custom App Exception
    }

    // 3. Map raw data to Document entity
    return Document.fromMap(rawData);
  }

  // --- Read (List) ---
  @override
  Future<List<Document>> getDocuments({
    String? status,
    String? type,
    String? memberId,
    DocumentSortField sortBy = DocumentSortField.updatedAt,
    SortDirection direction = SortDirection.descending,
    int page = 1,
    int limit = 20,
  }) async {
    // 1. Prepare parameters for the Data Source
    final filters = <String, dynamic>{
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (memberId != null) 'memberId': memberId,
    };

    // 2. Call Data Source
    final rawList = await dataSource.getDocuments(
      filters: filters,
      orderByField: sortBy,
      direction: direction,
      limit: limit,
      page: page,
    );

    // 3. Map raw list to Document entities
    return rawList.map(Document.fromMap).toList();
  }

  // READ
  @override
  Future<List<Document>> getDocumentsByCreator(String memberId) async {
    final rawList = await dataSource.getDocuments(
      filters: {'memberId': memberId},
      orderByField: DocumentSortField.updatedAt,
      direction: SortDirection.descending,
    );
    
    return rawList.map(Document.fromMap).toList();
  }

  // UPDATE
  @override
  Future<Document> updateDocument(Document document) async {
    // 1. Map the updated document to raw data
    final updateData = document.toMap();
    
    // 2. Call Data Source to update the fields
    await dataSource.updateDocument(document.id, updateData);
    
    // return the update doc object
    return document;
  }

  @override
  Future<Document> updateDocumentStatus(String id, String newStatus) async {
    final updateData = {'status': newStatus};
    await dataSource.updateDocument(id, updateData);

    // get the updated document to show on ui
    return getDocumentById(id);
  }

  // DELETE
  @override
  Future<void> deleteDocument(String id) async {
    return dataSource.deleteDocument(id);
  }
}