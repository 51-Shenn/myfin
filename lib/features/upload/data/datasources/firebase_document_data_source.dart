import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/upload/data/datasources/document_data_source.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class FirestoreDocumentDataSource implements DocumentDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'documents';

  FirestoreDocumentDataSource({required this.firestore});

  CollectionReference get _collectionRef => firestore.collection(collectionPath);

  // CREATE
  @override
  Future<String> createDocument(Map<String, dynamic> documentData) async {
    // add current timestamp when creating doc
    documentData['createdAt'] = FieldValue.serverTimestamp();
    documentData['updatedAt'] = FieldValue.serverTimestamp();
    
    final docRef = await _collectionRef.add(documentData);
    return docRef.id;
  }

  // READ
  @override
  Future<Map<String, dynamic>?> getDocument(String id) async {
    final docSnapshot = await _collectionRef.doc(id).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id; // Inject the ID here
      return data;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getDocuments({
    Map<String, dynamic>? filters,
    DocumentSortField? orderByField,
    SortDirection direction = SortDirection.descending,
    int? limit,
    int? page,
  }) async {
    Query query = _collectionRef;

    // apply filter to get doc that matches type and status
    if (filters?['status'] != null) {
      query = query.where('status', isEqualTo: filters!['status']);
    }
    if (filters?['type'] != null) {
      query = query.where('type', isEqualTo: filters!['type']);
    }

    // sort the list by sort field and direction
    if (orderByField != null) {
      final String sortField = orderByField.name;
      query = query.orderBy(
        sortField,
        descending: direction == SortDirection.descending,
      );
    }

    // get exactly how many document
    if (limit != null) {
      query = query.limit(limit);
    }
    // Pagination (using page) is complex with Firestore and often needs a
    // 'startAfter' cursor, which is typically handled in the Repository.

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the ID
      return data;
    }).toList();
  }

  // UPDATE
  @override
  Future<void> updateDocument(String id, Map<String, dynamic> updateData) async {
    // Ensure updatedAt is updated on every modification
    updateData['updatedAt'] = FieldValue.serverTimestamp(); 
    await _collectionRef.doc(id).update(updateData);
  }

  // DELETE
  @override
  Future<void> deleteDocument(String id) async {
    await _collectionRef.doc(id).delete();
  }
}