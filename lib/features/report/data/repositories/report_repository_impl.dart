import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/report/data/datasources/report_remote_data_source.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/services/generator/report_factory.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirestoreReportDataSource dataSource;
  final ProfileRemoteDataSource profileDataSource;

  ReportRepositoryImpl(this.dataSource, this.profileDataSource);

  @override
  Future<List<Report>> getReportsByMemberId(String memberId) async {
    // 1. Call Data Source to get raw report data
    final rawList = await dataSource.getReportsByMemberId(memberId);

    // 2. Map raw list to Report entities
    return rawList.map(ReportFactory.createReportFromJson).toList();
  }

  @override
  Future<Report> getReportByReportId(String reportId) async {
    // 1. Call Data Source to get raw report data
    final rawData = await dataSource.getReportByReportId(reportId);

    // 2. Handle null case
    if (rawData == null) {
      throw Exception('Report with ID $reportId not found.');
    }

    // 3. Map raw data to Report entity
    return ReportFactory.createReportFromJson(rawData);
  }

  @override
  Future<dynamic> getGeneratedReportByReportId(String reportId) async {
    // Fetch from reports collection (now contains full report data)
    final rawData = await dataSource.getReportByReportId(reportId);

    // Handle null case
    if (rawData == null) {
      throw Exception('Report with ID $reportId not found.');
    }

    // Determine report type and convert to appropriate entity
    final reportTypeString = rawData['report_type'] as String?;

    if (reportTypeString == null) {
      throw Exception('Report type not found in report data.');
    }

    final reportType = stringToReportType(reportTypeString);

    // Convert to specific report type based on report_type field
    switch (reportType) {
      case ReportType.profitLoss:
        return ProfitAndLossReport.fromMap(rawData);
      case ReportType.cashFlow:
        return CashFlowStatement.fromMap(rawData);
      case ReportType.balanceSheet:
        return BalanceSheet.fromMap(rawData);
      case ReportType.accountsReceivable:
        return AccountsReceivable.fromMap(rawData);
      case ReportType.accountsPayable:
        return AccountsPayable.fromMap(rawData);
    }
  }

  // generate report
  @override
  Future<dynamic> createReport(
    Report report,
    DateTime startDate,
    DateTime endDate,
  ) async {
    dynamic generatedReport = report;
    String generatedReportId = '';
    List<Document> docData = [];
    List<DocumentLineItem> docLineData = [];

    try {
      // Generate a document ID without saving yet
      generatedReportId = dataSource.generateReportId();
      report = report.copyWith(report_id: generatedReportId);

      // 1. Fetch all Posted, Paid, and Approved documents by memberId
      docData = await getDocumentsByMemberIdAndStatuses(report.member_id, [
        'Posted',
        'Paid',
        'Approved',
      ]);

      // 2. Extract document IDs from Posted documents
      final documentIds = docData.map((doc) => doc.id).toList();

      // 3. Fetch doc line items using the document IDs
      if (documentIds.isNotEmpty) {
        docLineData = await getDocLineItemsByDocumentIds(documentIds);
      }

      // Fetch business profile to get the name
      String businessName = "My Business";
      try {
        final businessProfile = await profileDataSource.fetchBusinessProfile(
          report.member_id,
        );
        if (businessProfile.name.isNotEmpty) {
          businessName = businessProfile.name;
        }
      } catch (e) {
        print("Error fetching business profile: $e");
        // Fallback to default name is already set
      }

      // 4. Pass both documents and line items to report generation
      generatedReport = await report.generateReport(
        businessName,
        docData,
        docLineData,
      );

      // 5. Save ONLY the full generated child report (e.g., ProfitAndLossReport) to Firestore
      final reportData = generatedReport.toMap();
      await dataSource.createReportLog(reportData);
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print(
          "Missing Firestore Index. Please create it using the link in the console logs.",
        );
      }
      print("Error generating report: ${e.message}");
      // Re-throw the exception so it can be handled by the BLoC
      rethrow;
    } on Exception catch (e) {
      print("Error generating report: $e");
      // Re-throw the exception so it can be handled by the BLoC
      rethrow;
    }

    return generatedReport;
  }

  @override
  Future<String> saveReportLog(Report report) async {
    final rawData = report.toMap();

    final docId = await dataSource.createReportLog(rawData);

    return docId;
  }

  @override
  Future<List<DocumentLineItem>> getDocLineItemsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocLineItemsByDateRange(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    // 2. Map raw list to DocumentLineItem entities
    return rawList.map(DocumentLineItem.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberId(String memberId) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocumentsByMemberId(memberId);

    // 2. Map raw list to Document entities
    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndStatus(
    String memberId,
    String status,
  ) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocumentsByMemberIdAndStatus(
      memberId,
      status,
    );

    // 2. Map raw list to Document entities
    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndStatuses(
    String memberId,
    List<String> statuses,
  ) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocumentsByMemberIdAndStatuses(
      memberId,
      statuses,
    );

    // 2. Map raw list to Document entities
    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocumentsByMemberIdAndDateRange(
      memberId,
      startDate,
      endDate,
    );

    // 2. Map raw list to Document entities
    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<DocumentLineItem>> getDocLineItemsByDocumentIds(
    List<String> documentIds,
  ) async {
    // 1. Call Data Source
    final rawList = await dataSource.getDocLineItemsByDocumentIds(documentIds);

    // 2. Map raw list to DocumentLineItem entities
    return rawList.map(DocumentLineItem.fromMap).toList();
  }
}
