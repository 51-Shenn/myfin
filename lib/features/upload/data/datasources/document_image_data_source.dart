abstract class DocumentImageDataSource {
  Future<void> saveImage(String documentId, String imageBase64);
  Future<String?> getImage(String documentId);
  Future<void> deleteImage(String documentId);
}
