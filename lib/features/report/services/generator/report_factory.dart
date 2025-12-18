// repo call to choose which report generator to use

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/report/domain/entities/report.dart';

class ReportFactory {
  static Report createReportFromJson(Map<String, dynamic> json) {
    final reportType = stringToReportType(json["report_type"]);
    final reportId = json["report_id"];

    // Handle generated_at which can be Timestamp (from Firestore) or String
    final generatedAt = _toDateTime(json["generated_at"]);

    // Handle fiscal_period which is stored as a JSON string
    final fiscalPeriod = _parseFiscalPeriod(json["fiscal_period"]);

    final memberId = json["member_id"];

    // create report based on type
    switch (reportType) {
      case ReportType.profitLoss:
        return ProfitAndLossReport(
          report_id: reportId,
          generated_at: generatedAt,
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          gross_profit: 0,
          operating_income: 0,
          income_before_tax: 0,
          income_tax_expense: 0,
          net_income: 0,
        );
      case ReportType.cashFlow:
        return CashFlowStatement(
          report_id: reportId,
          generated_at: generatedAt,
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          total_operating_cash_flow: 0,
          total_investing_cash_flow: 0,
          total_financing_cash_flow: 0,
          cash_balance: 0,
        );
      case ReportType.balanceSheet:
        return BalanceSheet(
          report_id: reportId,
          generated_at: generatedAt,
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          total_assets: 0,
          total_liabilities: 0,
          total_equity: 0,
          total_liabilities_and_equity: 0,
        );
      case ReportType.accountsPayable:
        return AccountsPayable(
          report_id: reportId,
          generated_at: generatedAt,
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          suppliers: [],
          total_payable: 0,
          total_overdue: 0,
          overdue_bill_count: 0,
        );
      case ReportType.accountsReceivable:
        return AccountsReceivable(
          report_id: reportId,
          generated_at: generatedAt,
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          customers: [],
          total_receivable: 0,
          total_overdue: 0,
          overdue_invoice_count: 0,
        );
    }
  }

  /// Creates a Report from event data (reportType string, memberId, and date range)
  static Report createReportFromEvent(
    String reportType,
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final type = stringToReportType(reportType);
    final reportId = '';
    final fiscalPeriod = {'startDate': startDate, 'endDate': endDate};

    switch (type) {
      case ReportType.profitLoss:
        return ProfitAndLossReport(
          report_id: reportId,
          generated_at: DateTime.now(),
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          gross_profit: 0,
          operating_income: 0,
          income_before_tax: 0,
          income_tax_expense: 0,
          net_income: 0,
        );
      case ReportType.cashFlow:
        return CashFlowStatement(
          report_id: reportId,
          generated_at: DateTime.now(),
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          total_operating_cash_flow: 0,
          total_investing_cash_flow: 0,
          total_financing_cash_flow: 0,
          cash_balance: 0,
        );
      case ReportType.balanceSheet:
        return BalanceSheet(
          report_id: reportId,
          generated_at: DateTime.now(),
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          sections: [],
          total_assets: 0,
          total_liabilities: 0,
          total_equity: 0,
          total_liabilities_and_equity: 0,
        );
      case ReportType.accountsPayable:
        return AccountsPayable(
          report_id: reportId,
          generated_at: DateTime.now(),
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          suppliers: [],
          total_payable: 0,
          total_overdue: 0,
          overdue_bill_count: 0,
        );
      case ReportType.accountsReceivable:
        return AccountsReceivable(
          report_id: reportId,
          generated_at: DateTime.now(),
          fiscal_period: fiscalPeriod,
          member_id: memberId,
          customers: [],
          total_receivable: 0,
          total_overdue: 0,
          overdue_invoice_count: 0,
        );
    }
  }

  // Helper method to convert various types to DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  // Helper method to parse fiscal_period (stored as JSON string)
  static Map<String, DateTime> _parseFiscalPeriod(dynamic value) {
    if (value is String) {
      // It's a JSON string, parse it
      final Map<String, dynamic> decoded = json.decode(value);
      return {
        "startDate": DateTime.parse(decoded["startDate"]),
        "endDate": DateTime.parse(decoded["endDate"]),
      };
    } else if (value is Map) {
      // It's already a Map (maybe from in-memory testing)
      return {
        "startDate": _toDateTime(value["startDate"]),
        "endDate": _toDateTime(value["endDate"]),
      };
    }
    // Fallback
    return {"startDate": DateTime.now(), "endDate": DateTime.now()};
  }
}
