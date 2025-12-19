import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

abstract class ReportRepository {
  // get all reports for a specific member
  Future<List<Report>> getReportsByMemberId(String memberId);

  // get a specific report by its ID
  Future<Report> getReportByReportId(String reportId);

  // get a generated report with full details by its ID
  Future<dynamic> getGeneratedReportByReportId(String reportId);

  // create/generate a new report
  Future<dynamic> createReport(
    Report report,
    DateTime startDate,
    DateTime endDate,
  );

  // save report to firebase
  Future<String> saveReportLog(Report report);

  // get document line items within a date range
  Future<List<DocumentLineItem>> getDocLineItemsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // get all documents for a specific member
  Future<List<Document>> getDocumentsByMemberId(String memberId);

  // get documents filtered by member ID and status
  Future<List<Document>> getDocumentsByMemberIdAndStatus(
    String memberId,
    String status,
  );

  // get documents filtered by member ID and status
  Future<List<Document>> getDocumentsByMemberIdAndStatuses(
    String memberId,
    List<String> statuses,
  );

  // get documents filtered by member ID and date range
  Future<List<Document>> getDocumentsByMemberIdAndDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  // get document line items filtered by document ID
  Future<List<DocumentLineItem>> getDocLineItemsByDocumentIds(
    List<String> documentIds,
  );

  Future<dynamic> getSalesTaxRegulation();

  Future<dynamic> getIncomeTaxRegulation();
}
