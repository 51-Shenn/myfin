abstract class DocumentLineItemDataSource {
  Future<String> createLineItem(Map<String, dynamic> lineItemData);
  Future<Map<String, dynamic>?> getLineItem(String lineItemId);
  
  Future<List<Map<String, dynamic>>> getLineItemsByDocumentId(
    String documentId, {
    int? limit,
    int? page,
  });

  Future<void> updateLineItem(String lineItemId, Map<String, dynamic> updateData);
  Future<void> deleteLineItem(String lineItemId);
  Future<void> deleteLineItemsByDocumentId(String documentId);
}