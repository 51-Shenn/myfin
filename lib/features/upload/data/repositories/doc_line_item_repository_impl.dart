import 'package:myfin/features/upload/data/datasources/doc_line_data_source.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';

class DocumentLineItemRepositoryImpl implements DocumentLineItemRepository {
  final DocumentLineItemDataSource dataSource;

  DocumentLineItemRepositoryImpl(this.dataSource);

  @override
  Future<DocumentLineItem> createLineItem(DocumentLineItem lineItem) async {
    final rawData = lineItem.toMap();
    final lineItemId = await dataSource.createLineItem(rawData);

    return DocumentLineItem(
      lineItemId: lineItemId,
      documentId: lineItem.documentId,
      lineNo: lineItem.lineNo,
      lineDate: lineItem.lineDate,
      categoryCode: lineItem.categoryCode,
      description: lineItem.description,
      debit: lineItem.debit,
      credit: lineItem.credit,
      attribute: lineItem.attribute,
    );
  }

  @override
  Future<DocumentLineItem> getLineItemById(String lineItemId) async {
    final rawData = await dataSource.getLineItem(lineItemId);

    if (rawData == null) {
      throw Exception('Line item with ID $lineItemId not found.');
    }

    return DocumentLineItem.fromMap(rawData);
  }

  @override
  Future<List<DocumentLineItem>> getLineItemsByDocumentId(
    String documentId,
  ) async {
    final rawList = await dataSource.getLineItemsByDocumentId(documentId);
    return rawList.map((data) => DocumentLineItem.fromMap(data)).toList();
  }

  @override
  Future<DocumentLineItem> updateLineItem(DocumentLineItem lineItem) async {
    final updateData = lineItem.toMap();
    await dataSource.updateLineItem(lineItem.lineItemId, updateData);
    return lineItem;
  }

  @override
  Future<void> deleteLineItem(String lineItemId) async {
    await dataSource.deleteLineItem(lineItemId);
  }

  @override
  Future<void> deleteLineItemsByDocumentId(String documentId) async {
    await dataSource.deleteLineItemsByDocumentId(documentId);
  }

  @override
  Future<List<DocumentLineItem>> getLineItems({
    required String documentId,
    int page = 1,
    int limit = 20,
  }) async {
    final rawList = await dataSource.getLineItemsByDocumentId(
      documentId,
      limit: limit,
      page: page,
    );
    return rawList.map((data) => DocumentLineItem.fromMap(data)).toList();
  }
}