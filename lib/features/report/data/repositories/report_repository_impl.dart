import 'dart:async';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/generator/report_factory.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

// repo implementation
class ReportRepository {
  // testing
  final List<Map<String, dynamic>> _exampleCollection = [
    {
      "report_id": "RPT-001",
      "generated_at": "2024-11-10T08:30:00Z",
      "fiscal_period": {"startDate": "2024-01-01T00:00:00Z", "endDate": "2024-12-31T23:59:59Z"},
      "report_type": "Balance Sheet",
      "member_id": "M123",
    },
    {
      "report_id": "RPT-002",
      "generated_at": "2024-10-02T12:00:00Z",
      "fiscal_period": {"startDate": "2025-01-01T00:00:00Z", "endDate": "2025-12-31T23:59:59Z"},
      "report_type": "Profit & Loss Report",
      "member_id": "M123",
    },
  ];

  Future<List<Report>> fetchReportsForMember(String memberId) async {
    final memberReports = _exampleCollection
        .where((doc) => doc["member_id"] == memberId)
        .map(ReportFactory.createReportFromJson)
        .toList();
    return memberReports;
  }

  Future<Report> getReportByReportId(String reportId) async {
    final report = _exampleCollection
        .where((doc) => doc["report_id"] == reportId)
        .map(ReportFactory.createReportFromJson)
        .first;
    return report;
  }

  // generate report
  Future<Report> createReport(Report report) async {
    Report generatedReport = report;
    String generatedReportId = '';
    List<DocumentLineItem> reportData = [];

    try {
      // TODO: saveReportLog(report); - return report id
      report.copyWith(report_id: generatedReportId);

      // TODO: reportData = await getReportData(report); - repo function

      // TODO: get business profile
      String businessName = "ABC Corp Sdn. Bhd.";

      generatedReport = await report.generateReport(businessName, reportData);
    } on Exception catch (e) {
      print("Error generating report: $e");
    }

    return generatedReport;
  }
}
