// API calls to fetch data from firebase

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReportDataSource {
  final FirebaseFirestore firestore;
  final String docLineItemCollectionPath = 'document_line_items';

  FirestoreReportDataSource({required this.firestore});

  CollectionReference get _collectionRef =>
      firestore.collection(docLineItemCollectionPath);

  Future<String> saveReportLog(Map<String, dynamic> reportData) async {
    // add current timestamp when creating report
    reportData['generated_at'] = FieldValue.serverTimestamp();

    final docRef = await _collectionRef.add(reportData);
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getDocLineItemsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _collectionRef;

    // 1. Apply Date Range Filtering
    // Filtering documents where 'lineDate' is on or after startDate
    if (startDate != null) {
      query = query.where(
        'lineDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    // Filtering documents where 'lineDate' is on or before endDate
    if (endDate != null) {
      query = query.where(
        'lineDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    // 2. Apply Limit
    if (limit != null) {
      query = query.limit(limit);
    }

    // 3. Fetch and Process
    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the Document ID
      return data;
    }).toList();
  }
}
