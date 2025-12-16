import 'package:myfin/features/upload/data/datasources/doc_line_data_source.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';

class DocumentLineItemRepositoryImpl implements DocumentLineItemRepository {
  final DocumentLineItemDataSource dataSource;

  DocumentLineItemRepositoryImpl(this.dataSource);

  @override
  Future<DocumentLineItem> createLineItem(DocumentLineItem lineItem) async {
    final data = lineItem.toMap();
    // Remove the ID if it's empty so Firestore generates one, 
    // or keep it if you are generating IDs client-side.
    if (lineItem.lineItemId.isEmpty) {
      data.remove('lineItemId');
    }
    
    final id = await dataSource.createLineItem(data);
    
    return lineItem.copyWith(lineItemId: id);
  }

  @override
  Future<DocumentLineItem> getLineItemById(String lineItemId) async {
    final data = await dataSource.getLineItem(lineItemId);
    if (data == null) throw Exception('Line Item not found');
    return DocumentLineItem.fromMap(data);
  }

  @override
  Future<List<DocumentLineItem>> getLineItemsByDocumentId(String documentId) async {
    final result = await dataSource.getLineItemsByDocumentId(documentId);
    return result.map((data) => DocumentLineItem.fromMap(data)).toList();
  }

  @override
  Future<DocumentLineItem> updateLineItem(DocumentLineItem lineItem) async {
    await dataSource.updateLineItem(lineItem.lineItemId, lineItem.toMap());
    return lineItem;
  }

  @override
  Future<void> deleteLineItem(String lineItemId) async {
    return dataSource.deleteLineItem(lineItemId);
  }

  @override
  Future<void> deleteLineItemsByDocumentId(String documentId) async {
    return dataSource.deleteLineItemsByDocumentId(documentId);
  }

  @override
  Future<List<DocumentLineItem>> getLineItems({
    required String documentId,
    int page = 1,
    int limit = 20,
  }) async {
    // Basic implementation delegating to the datasource
    final result = await dataSource.getLineItemsByDocumentId(
      documentId, 
      limit: limit, 
      page: page
    );
    return result.map((data) => DocumentLineItem.fromMap(data)).toList();
  }
}