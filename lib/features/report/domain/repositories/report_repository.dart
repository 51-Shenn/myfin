// Abstract repository interface for report feature
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

abstract class ReportRepository {
  /// Fetch all reports for a specific member
  Future<List<Report>> getReportsByMemberId(String memberId);

  /// Get a specific report by its ID
  Future<Report> getReportByReportId(String reportId);

  /// Get a generated report with full details (sections, calculations) by its ID
  Future<dynamic> getGeneratedReportByReportId(String reportId);

  /// Create/generate a new report
  Future<dynamic> createReport(
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

  /// Get all documents for a specific member
  Future<List<Document>> getDocumentsByMemberId(String memberId);

  /// Get documents filtered by member ID and status
  Future<List<Document>> getDocumentsByMemberIdAndStatus(
    String memberId,
    String status,
  );

  /// Get documents filtered by member ID and multiple statuses
  Future<List<Document>> getDocumentsByMemberIdAndStatuses(
    String memberId,
    List<String> statuses,
  );

  /// Get documents filtered by member ID and date range
  Future<List<Document>> getDocumentsByMemberIdAndDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get document line items filtered by document IDs
  Future<List<DocumentLineItem>> getDocLineItemsByDocumentIds(
    List<String> documentIds,
  );
}
