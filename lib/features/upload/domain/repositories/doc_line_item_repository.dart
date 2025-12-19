import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

abstract class DocumentLineItemRepository {
  // create a new line item for a document
  Future<DocumentLineItem> createLineItem(DocumentLineItem lineItem);

  // get a specific line item by ID
  Future<DocumentLineItem> getLineItemById(String lineItemId);

  // get all line items for a specific document
  Future<List<DocumentLineItem>> getLineItemsByDocumentId(String documentId);

  // update an existing line item
  Future<DocumentLineItem> updateLineItem(DocumentLineItem lineItem);

  // delete a line item
  Future<void> deleteLineItem(String lineItemId);

  // delete all line items for a document
  Future<void> deleteLineItemsByDocumentId(String documentId);

  // get line items with pagination
  Future<List<DocumentLineItem>> getLineItems({
    required String documentId,
    int page = 1,
    int limit = 20,
  });
}