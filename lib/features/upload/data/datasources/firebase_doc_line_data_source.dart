import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/upload/data/datasources/doc_line_data_source.dart';

class FirestoreDocumentLineItemDataSource implements DocumentLineItemDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'document_line_items';

  FirestoreDocumentLineItemDataSource({required this.firestore});

  CollectionReference get _collectionRef => firestore.collection(collectionPath);

  @override
  Future<String> createLineItem(Map<String, dynamic> lineItemData) async {
    final docRef = await _collectionRef.add(lineItemData);
    return docRef.id;
  }

  @override
  Future<Map<String, dynamic>?> getLineItem(String lineItemId) async {
    final docSnapshot = await _collectionRef.doc(lineItemId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['lineItemId'] = docSnapshot.id;
      return data;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getLineItemsByDocumentId(
    String documentId, {
    int? limit,
    int? page,
  }) async {
    Query query = _collectionRef.where('documentId', isEqualTo: documentId);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['lineItemId'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Future<void> updateLineItem(String lineItemId, Map<String, dynamic> updateData) async {
    await _collectionRef.doc(lineItemId).update(updateData);
  }

  @override
  Future<void> deleteLineItem(String lineItemId) async {
    await _collectionRef.doc(lineItemId).delete();
  }

  @override
  Future<void> deleteLineItemsByDocumentId(String documentId) async {
    final querySnapshot = await _collectionRef
        .where('documentId', isEqualTo: documentId)
        .get();
    
    final batch = firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}