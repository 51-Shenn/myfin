import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/data/datasources/tax_regulation_remote_data_source.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
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
  final TaxRegulationRemoteDataSource taxRegulationDataSource;

  ReportRepositoryImpl(
    this.dataSource,
    this.profileDataSource,
    this.taxRegulationDataSource,
  );

  @override
  Future<List<Report>> getReportsByMemberId(String memberId) async {
    // call data source to get raw report data
    final rawList = await dataSource.getReportsByMemberId(memberId);

    // map raw list to report entities
    return rawList.map(ReportFactory.createReportFromJson).toList();
  }

  @override
  Future<Report> getReportByReportId(String reportId) async {
    final rawData = await dataSource.getReportByReportId(reportId);

    if (rawData == null) {
      throw Exception('Report with ID $reportId not found.');
    }

    return ReportFactory.createReportFromJson(rawData);
  }

  @override
  Future<dynamic> getGeneratedReportByReportId(String reportId) async {
    final rawData = await dataSource.getReportByReportId(reportId);

    if (rawData == null) {
      throw Exception('Report with ID $reportId not found.');
    }

    final reportTypeString = rawData['report_type'] as String?;

    if (reportTypeString == null) {
      throw Exception('Report type not found in report data.');
    }

    final reportType = stringToReportType(reportTypeString);

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
      generatedReportId = dataSource.generateReportId();
      report = report.copyWith(report_id: generatedReportId);

      docData = await getDocumentsByMemberIdAndStatuses(report.member_id, [
        'Posted',
        'Paid',
        'Approved',
      ]);

      final documentIds = docData.map((doc) => doc.id).toList();

      if (documentIds.isNotEmpty) {
        docLineData = await getDocLineItemsByDocumentIds(documentIds);
      }

      // getch business profile to get the name
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
      }

      TaxRegulation? salesTaxRegulation;
      TaxRegulation? incomeTaxRegulation;

      if (report is BalanceSheet) {
        try {
          salesTaxRegulation = await getSalesTaxRegulation();
          incomeTaxRegulation = await getIncomeTaxRegulation();
        } catch (e) {
          print("Error fetching tax regulations: $e");
        }
      }

      if (report is BalanceSheet) {
        generatedReport = await report.generateReport(
          businessName,
          docData,
          docLineData,
          salesTaxRegulation: salesTaxRegulation,
          incomeTaxRegulation: incomeTaxRegulation,
        );
      } else {
        generatedReport = await report.generateReport(
          businessName,
          docData,
          docLineData,
        );
      }

      final reportData = generatedReport.toMap();
      await dataSource.createReportLog(reportData);
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print(
          "Missing Firestore Index. Please create it using the link in the console logs.",
        );
      }
      print("Error generating report: ${e.message}");
      rethrow;
    } on Exception catch (e) {
      print("Error generating report: $e");
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
    final rawList = await dataSource.getDocLineItemsByDateRange(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    return rawList.map(DocumentLineItem.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberId(String memberId) async {
    final rawList = await dataSource.getDocumentsByMemberId(memberId);

    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndStatus(
    String memberId,
    String status,
  ) async {
    final rawList = await dataSource.getDocumentsByMemberIdAndStatus(
      memberId,
      status,
    );

    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndStatuses(
    String memberId,
    List<String> statuses,
  ) async {
    final rawList = await dataSource.getDocumentsByMemberIdAndStatuses(
      memberId,
      statuses,
    );

    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<Document>> getDocumentsByMemberIdAndDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rawList = await dataSource.getDocumentsByMemberIdAndDateRange(
      memberId,
      startDate,
      endDate,
    );

    return rawList.map(Document.fromMap).toList();
  }

  @override
  Future<List<DocumentLineItem>> getDocLineItemsByDocumentIds(
    List<String> documentIds,
  ) async {
    final rawList = await dataSource.getDocLineItemsByDocumentIds(documentIds);

    return rawList.map(DocumentLineItem.fromMap).toList();
  }

  @override
  Future<TaxRegulation?> getSalesTaxRegulation() async {
    try {
      final model = await taxRegulationDataSource.getTaxRegulationByType(
        'Sales & Service',
      );
      return model?.toEntity();
    } catch (e) {
      print('Error fetching sales tax regulation: $e');
      return null;
    }
  }

  @override
  Future<TaxRegulation?> getIncomeTaxRegulation() async {
    try {
      final model = await taxRegulationDataSource.getTaxRegulationByType(
        'Income Tax',
      );
      return model?.toEntity();
    } catch (e) {
      print('Error fetching income tax regulation: $e');
      return null;
    }
  }
}
