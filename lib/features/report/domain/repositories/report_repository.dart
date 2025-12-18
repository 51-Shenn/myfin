// Abstract repository interface for report feature
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

abstract class ReportRepository {
  /// Fetch all reports for a specific member
  Future<List<Report>> fetchReportsForMember(String memberId);

  /// Get a specific report by its ID
  Future<Report> getReportByReportId(String reportId);

  /// Create/generate a new report
  Future<Report> createReport(
    Report report,
    DateTime startDate,
    DateTime endDate,
  );

  /// Save report log to database
  Future<String> saveReportLog(Report report);

  /// Get document line items within a date range
  Future<List<DocumentLineItem>> getDocLineItemsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
}
