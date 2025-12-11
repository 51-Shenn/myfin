// concrete data models

import 'package:equatable/equatable.dart';

// report types
enum ReportType {
  profitLoss,
  cashFlow,
  balanceSheet,
  accountsPayable,
  accountsReceivable,
}

// toString extension for ReportType
extension ReportTypeExtension on ReportType {
  String get convertString {
    switch (this) {
      case ReportType.profitLoss:
        return 'Profit & Loss Report';
      case ReportType.balanceSheet:
        return 'Balance Sheet';
      case ReportType.cashFlow:
        return 'Cash Flow Statement';
      case ReportType.accountsPayable:
        return 'Accounts Payable';
      case ReportType.accountsReceivable:
        return 'Accounts Receivable';
    }
  }
}

// report entity
class Report extends Equatable {
  final String report_id;
  final DateTime generated_at;
  final Map<String, DateTime> fiscal_period;
  final ReportType report_type;
  final String member_id;

  const Report({
    required this.report_id,
    required this.generated_at,
    required this.fiscal_period,
    required this.report_type,
    required this.member_id,
  });

  @override
  String toString() {
    return 'Report(ID: $report_id, Type: $report_type, Period: ${fiscal_period['startDate']} - ${fiscal_period['endDate']})';
  }

  @override
  List<Object> get props => [
    report_id,
    generated_at,
    fiscal_period,
    member_id,
    report_type,
  ];
}

// report line item entity
class ReportLineItem extends Equatable {
  final String item_title;
  final String? description;
  final double amount;
  final bool isIncrease;

  const ReportLineItem({
    required this.item_title,
    this.description,
    required this.amount,
    required this.isIncrease,
  });

  @override
  List<Object?> get props => [item_title, description, amount, isIncrease];
}

// report group entity
class ReportGroup extends Equatable {
  final String group_title;
  final List<ReportLineItem> line_items;
  final double subtotal;

  const ReportGroup({
    required this.group_title,
    required this.line_items,
    required this.subtotal,
  });

  @override
  List<Object> get props => [group_title, line_items, subtotal];
}

// report section entity
class ReportSection extends Equatable {
  final String section_title;
  final List<ReportGroup> groups;
  final double grand_total;

  const ReportSection({
    required this.section_title,
    required this.groups,
    required this.grand_total,
  });

  @override
  List<Object> get props => [section_title, groups, grand_total];
}

// profit & loss report entity
class ProfitAndLossReport extends Report {
  final List<ReportSection> sections;
  final double gross_profit;
  final double operating_income;
  final double income_before_tax;
  final double income_tax_expense;
  final double net_income;

  const ProfitAndLossReport({
    required super.report_id,
    required super.generated_at,
    required super.fiscal_period,
    required super.member_id,
    required this.sections,
    required this.gross_profit,
    required this.operating_income,
    required this.income_before_tax,
    required this.income_tax_expense,
    required this.net_income,
  }) : super(report_type: ReportType.profitLoss);

  @override
  String toString() {
    // Use existing fields for revenue and net income.
    return '${super.toString()}: '
        'Gross Profit: $gross_profit, '
        'Operating Income: $operating_income, '
        'Net Income: $net_income';
  }

  @override
  List<Object> get props => [
    ...super.props,
    sections,
    gross_profit,
    operating_income,
    income_before_tax,
    income_tax_expense,
    net_income,
  ];
}

// cash flow statement entity
class CashFlowStatement extends Report {
  final List<ReportSection> sections;
  final double total_operating_cash_flow;
  final double total_investing_cash_flow;
  final double total_financing_cash_flow;
  final double cash_balance;

  const CashFlowStatement({
    required super.report_id,
    required super.generated_at,
    required super.fiscal_period,
    required super.member_id,
    required this.sections,
    required this.total_operating_cash_flow,
    required this.total_investing_cash_flow,
    required this.total_financing_cash_flow,
    required this.cash_balance,
  }) : super(report_type: ReportType.profitLoss);

  @override
  String toString() {
    // Use existing fields for revenue and net income.
    return '${super.toString()}: '
        'Total Operating Cash Flow: $total_operating_cash_flow, '
        'Total Investing Cash Flow: $total_investing_cash_flow, '
        'Total Financing Cash Flow: $total_financing_cash_flow, '
        'Cash Balance: $cash_balance';
  }

  @override
  List<Object> get props => [
    ...super.props,
    sections,
    total_operating_cash_flow,
    total_investing_cash_flow,
    total_financing_cash_flow,
    cash_balance,
  ];
}

// balance sheet entity
class BalanceSheet extends Report {
  final List<ReportSection> sections;
  final double total_assets;
  final double total_liabilities;
  final double total_equity;
  final double total_liabilities_and_equity;

  const BalanceSheet({
    required super.report_id,
    required super.generated_at,
    required super.fiscal_period,
    required super.member_id,
    required this.sections,
    required this.total_assets,
    required this.total_liabilities,
    required this.total_equity,
    required this.total_liabilities_and_equity,
  }) : super(report_type: ReportType.profitLoss);

  @override
  String toString() {
    // Use existing fields for revenue and net income.
    return '${super.toString()}: '
        'Total Assets: $total_assets, '
        'Total Liabilities: $total_liabilities, '
        'Total Equity: $total_equity, '
        'Total Liabilities + Equity: $total_liabilities_and_equity';
  }

  @override
  List<Object> get props => [
    ...super.props,
    sections,
    total_assets,
    total_liabilities,
    total_equity,
    total_liabilities_and_equity,
  ];
}

// accounts receivable entity
// accounts payable entity
