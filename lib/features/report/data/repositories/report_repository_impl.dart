import 'dart:async';
import 'package:myfin/features/report/data/datasources/report_remote_data_source.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/services/generator/report_factory.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

// repo implementation
class ReportRepositoryImpl implements ReportRepository {
  final FirestoreReportDataSource dataSource;

  ReportRepositoryImpl(this.dataSource);

  // testing
  final List<Map<String, dynamic>> _exampleCollection = [
    {
      "report_id": "RPT-001",
      "generated_at": "2024-11-10T08:30:00Z",
      "fiscal_period": {
        "startDate": "2024-01-01T00:00:00Z",
        "endDate": "2024-12-31T23:59:59Z",
      },
      "report_type": "Balance Sheet",
      "member_id": "M123",
    },
    {
      "report_id": "RPT-002",
      "generated_at": "2024-10-02T12:00:00Z",
      "fiscal_period": {
        "startDate": "2025-01-01T00:00:00Z",
        "endDate": "2025-12-31T23:59:59Z",
      },
      "report_type": "Profit & Loss Report",
      "member_id": "M123",
    },
  ];

  @override
  Future<List<Report>> fetchReportsForMember(String memberId) async {
    final memberReports = _exampleCollection
        .where((doc) => doc["member_id"] == memberId)
        .map(ReportFactory.createReportFromJson)
        .toList();
    return memberReports;
  }

  @override
  Future<Report> getReportByReportId(String reportId) async {
    final report = _exampleCollection
        .where((doc) => doc["report_id"] == reportId)
        .map(ReportFactory.createReportFromJson)
        .first;
    return report;
  }

  // generate report
  @override
  Future<Report> createReport(
    Report report,
    DateTime startDate,
    DateTime endDate,
  ) async {
    Report generatedReport = report;
    String generatedReportId = '';
    List<Document> docData = [];
    List<DocumentLineItem> docLineData = [];

    try {
      generatedReportId = await saveReportLog(report);
      report.copyWith(report_id: generatedReportId);

      // TODO: List<Document> docData = await getDocData(report); - repo function
      docLineData = await getDocLineItemsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      // TODO: get business profile
      String businessName = "ABC Corp Sdn. Bhd.";

      generatedReport = await report.generateReport(
        businessName,
        docData,
        docLineData,
      );
    } on Exception catch (e) {
      print("Error generating report: $e");
    }

    return generatedReport;
  }

  @override
  Future<String> saveReportLog(Report report) async {
    final rawData = report.toMap();

    final docId = await dataSource.saveReportLog(rawData);

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

    // 2. Map raw list to Document entities
    return rawList.map(DocumentLineItem.fromMap).toList();
  }
}
