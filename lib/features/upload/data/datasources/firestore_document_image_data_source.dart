import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/upload/data/datasources/document_image_data_source.dart';

class FirestoreDocumentImageDataSource implements DocumentImageDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'document_images';

  FirestoreDocumentImageDataSource({required this.firestore});

  CollectionReference get _collectionRef =>
      firestore.collection(collectionPath);

  @override
  Future<void> saveImage(String documentId, String imageBase64) async {
    final data = {
      'imageBase64': imageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Check if image document exists
    final docSnapshot = await _collectionRef.doc(documentId).get();

    if (docSnapshot.exists) {
      // Update existing
      await _collectionRef.doc(documentId).update(data);
    } else {
      // Create new
      data['createdAt'] = FieldValue.serverTimestamp();
      await _collectionRef.doc(documentId).set(data);
    }
  }

  @override
  Future<String?> getImage(String documentId) async {
    final docSnapshot = await _collectionRef.doc(documentId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return data['imageBase64'] as String?;
    }

    return null;
  }

  @override
  Future<void> deleteImage(String documentId) async {
    await _collectionRef.doc(documentId).delete();
  }
}
