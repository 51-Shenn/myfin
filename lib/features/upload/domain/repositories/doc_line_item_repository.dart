import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

abstract class DocumentLineItemRepository {
  // Create a new line item for a document
  Future<DocumentLineItem> createLineItem(DocumentLineItem lineItem);

  // Get a specific line item by ID
  Future<DocumentLineItem> getLineItemById(String lineItemId);

  // Get all line items for a specific document
  Future<List<DocumentLineItem>> getLineItemsByDocumentId(String documentId);

  // Update an existing line item
  Future<DocumentLineItem> updateLineItem(DocumentLineItem lineItem);

  // Delete a line item
  Future<void> deleteLineItem(String lineItemId);

  // Delete all line items for a document
  Future<void> deleteLineItemsByDocumentId(String documentId);

  // Get line items with pagination
  Future<List<DocumentLineItem>> getLineItems({
    required String documentId,
    int page = 1,
    int limit = 20,
  });
}