import 'package:myfin/features/upload/data/datasources/document_data_source.dart';
import 'package:myfin/features/upload/data/datasources/doc_line_data_source.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/dashboard/domain/usecases/main_category_mapper.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentDataSource dataSource;
  final DocumentLineItemDataSource lineItemDataSource;

  DocumentRepositoryImpl(this.dataSource, this.lineItemDataSource);

  // create
  @override
  Future<Document> createDocument(Document document) async {
    final rawData = document.toMap();

    final docId = await dataSource.createDocument(rawData);

    return Document(
      id: docId,
      name: document.name,
      type: document.type,
      status: document.status,
      createdBy: document.createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      postingDate: document.postingDate,
      metadata: document.metadata,
      refDocType: document.refDocType,
      refDocId: document.refDocId,
      memberId: document.memberId,
    );
  }

  // read
  @override
  Future<Document> getDocumentById(String id) async {
    final rawData = await dataSource.getDocument(id);

    if (rawData == null) {
      throw Exception(
        'Document with ID $id not found.',
      );
    }

    return Document.fromMap(rawData);
  }

  // read
  @override
  Future<List<Document>> getDocuments({
    String? status,
    String? type,
    String? memberId,
    DocumentSortField sortBy = DocumentSortField.updatedAt,
    SortDirection direction = SortDirection.descending,
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final filters = <String, dynamic>{
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (memberId != null) 'memberId': memberId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final rawList = await dataSource.getDocuments(
      filters: filters,
      orderByField: sortBy,
      direction: direction,
      limit: limit,
      page: page,
    );

    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByCreator(String memberId) async {
    final rawList = await dataSource.getDocuments(
      filters: {'memberId': memberId},
      orderByField: DocumentSortField.updatedAt,
      direction: SortDirection.descending,
    );

    return rawList.map(Document.fromMap).toList();
  }

  // update
  @override
  Future<Document> updateDocument(Document document) async {
    final updateData = document.toMap();
    await dataSource.updateDocument(document.id, updateData);
    return document;
  }

  @override
  Future<Document> updateDocumentStatus(String id, String newStatus) async {
    final updateData = {'status': newStatus};
    await dataSource.updateDocument(id, updateData);

    // get the updated document to show on ui
    return getDocumentById(id);
  }

  // delete
  @override
  Future<void> deleteDocument(String id) async {
    return dataSource.deleteDocument(id);
  }

  @override
  Future<List<Document>> getDocumentsByMainCategory({
    required String memberId,
    required String mainCategory,
    required String transactionType,
    required DateTime startDate,
    required DateTime endDate,
    DocumentSortField sortBy = DocumentSortField.postingDate,
    SortDirection direction = SortDirection.descending,
    int page = 1,
    int limit = 50,
  }) async {
    var allDocs = await getDocuments(
      memberId: memberId,
      sortBy: sortBy,
      direction: direction,
      limit: 1000,
    );

    allDocs = allDocs.where((doc) {
      return doc.postingDate.isAfter(
            startDate.subtract(const Duration(seconds: 1)),
          ) &&
          doc.postingDate.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    final matchingDocs = <Document>[];

    for (final doc in allDocs) {
      // get line items for this document
      final lineItemsData = await lineItemDataSource.getLineItemsByDocumentId(
        doc.id,
      );
      final lineItems = lineItemsData
          .map((data) => DocumentLineItem.fromMap(data))
          .toList();

      // check if any line item maps to the target main category
      final hasMatchingCategory = lineItems.any((item) {
        if (transactionType == 'income' && item.credit <= 0) return false;
        if (transactionType == 'expense' && item.debit <= 0) return false;

        final itemMainCategory = MainCategoryMapper.getMainCategory(
          item.categoryCode,
          transactionType,
        );
        return itemMainCategory == mainCategory;
      });

      if (hasMatchingCategory) {
        matchingDocs.add(doc);
      }
    }

    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= matchingDocs.length) {
      return [];
    }

    return matchingDocs.sublist(
      startIndex,
      endIndex > matchingDocs.length ? matchingDocs.length : endIndex,
    );
  }
}
