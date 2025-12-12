// repo call to choose which report generator to use

import 'package:myfin/features/report/domain/entities/report.dart';

class ReportFactory {
  Future<Report> generateReport(
    Report report,
    List<Map<dynamic, dynamic>> reportData,
  ) async {
    Report generatedReport = report;

    if (report.report_type == ReportType.profitLoss) {
      // TODO: call Profit and Loss Generator
    } else if (report.report_type == ReportType.cashFlow) {
      // TODO: call Cash Flow Generator
    } else if (report.report_type == ReportType.balanceSheet) {
      // TODO: call Balance Sheet Generator
    } else if (report.report_type == ReportType.accountsPayable) {
      // TODO: call Accounts Payable Generator
    } else if (report.report_type == ReportType.accountsReceivable) {
      // TODO: call Accounts Receivable Generator
    } else {
      throw Exception('Unsupported report type: $report.reportType');
    }

    return generatedReport;
  }
}
