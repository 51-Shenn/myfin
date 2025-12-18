// API calls to fetch data from firebase

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReportDataSource {
  final FirebaseFirestore firestore;
  final String docLineItemCollectionPath = 'document_line_items';
  final String documentCollectionPath = 'documents';
  final String reportCollectionPath = 'reports';

  FirestoreReportDataSource({required this.firestore});

  CollectionReference get _docLineItemCollectionRef =>
      firestore.collection(docLineItemCollectionPath);

  CollectionReference get _documentCollectionRef =>
      firestore.collection(documentCollectionPath);

  CollectionReference get _reportCollectionRef =>
      firestore.collection(reportCollectionPath);

  /// Generate a report ID without saving the document
  String generateReportId() {
    return _reportCollectionRef.doc().id;
  }

  /// Create a report document in Firestore (supports all report types)
  Future<String> createReportLog(Map<String, dynamic> reportData) async {
    final reportRef = _reportCollectionRef.doc();

    // add current timestamp when creating report
    reportData['generated_at'] = Timestamp.now();

    await reportRef.set(reportData);
    await reportRef.update({'report_id': reportRef.id});

    return reportRef.id;
  }

  /// Get all reports for a specific member
  Future<List<Map<String, dynamic>>> getReportsByMemberId(
    String memberId,
  ) async {
    final querySnapshot = await _reportCollectionRef
        .where('member_id', isEqualTo: memberId)
        .orderBy('generated_at', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['report_id'] = doc.id; // Ensure report_id is set
      return data;
    }).toList();
  }

  /// Get a specific report by report ID
  Future<Map<String, dynamic>?> getReportByReportId(String reportId) async {
    final docSnapshot = await _reportCollectionRef.doc(reportId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['report_id'] = docSnapshot.id; // Ensure report_id is set
      return data;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getDocLineItemsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _docLineItemCollectionRef;

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

  /// Get all documents for a specific member
  Future<List<Map<String, dynamic>>> getDocumentsByMemberId(
    String memberId,
  ) async {
    final querySnapshot = await _documentCollectionRef
        .where('memberId', isEqualTo: memberId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the Document ID
      return data;
    }).toList();
  }

  /// Get documents filtered by member ID and status
  Future<List<Map<String, dynamic>>> getDocumentsByMemberIdAndStatus(
    String memberId,
    String status,
  ) async {
    final querySnapshot = await _documentCollectionRef
        .where('memberId', isEqualTo: memberId)
        .where('status', isEqualTo: status)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the Document ID
      return data;
    }).toList();
  }

  /// Get documents filtered by member ID and multiple statuses
  Future<List<Map<String, dynamic>>> getDocumentsByMemberIdAndStatuses(
    String memberId,
    List<String> statuses,
  ) async {
    if (statuses.isEmpty) {
      return [];
    }

    final querySnapshot = await _documentCollectionRef
        .where('memberId', isEqualTo: memberId)
        .where('status', whereIn: statuses)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the Document ID
      return data;
    }).toList();
  }

  /// Get documents filtered by member ID and date range (using postingDate)
  Future<List<Map<String, dynamic>>> getDocumentsByMemberIdAndDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    Query query = _documentCollectionRef;

    // Filter by memberId
    query = query.where('memberId', isEqualTo: memberId);

    // Filter by postingDate range
    query = query.where(
      'postingDate',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
    );
    query = query.where(
      'postingDate',
      isLessThanOrEqualTo: Timestamp.fromDate(endDate),
    );

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Inject the Document ID
      return data;
    }).toList();
  }

  /// Get document line items filtered by document IDs
  /// Note: Firestore 'whereIn' has a limit of 10 items, so we need to batch if more
  Future<List<Map<String, dynamic>>> getDocLineItemsByDocumentIds(
    List<String> documentIds,
  ) async {
    if (documentIds.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> allResults = [];

    // Firestore whereIn limit is 10, so we need to batch the queries
    const int batchSize = 10;
    for (int i = 0; i < documentIds.length; i += batchSize) {
      final batch = documentIds.skip(i).take(batchSize).toList();

      final querySnapshot = await _docLineItemCollectionRef
          .where('documentId', whereIn: batch)
          .get();

      final batchResults = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Inject the Document ID
        return data;
      }).toList();

      allResults.addAll(batchResults);
    }

    return allResults;
  }
}
