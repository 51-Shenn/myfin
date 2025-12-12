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
  String get reportTypeToString {
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

// convert String to ReportType
ReportType stringToReportType(String type) {
  switch (type) {
    case 'Profit & Loss Report':
      return ReportType.profitLoss;
    case 'Balance Sheet':
      return ReportType.balanceSheet;
    case 'Cash Flow Statement':
      return ReportType.cashFlow;
    case 'Accounts Payable':
      return ReportType.accountsPayable;
    case 'Accounts Receivable':
      return ReportType.accountsReceivable;
    default:
      throw Exception('Unknown report type: $type');
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

  Report copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
  }) {
    return Report(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      report_type: report_type ?? this.report_type,
      member_id: member_id ?? this.member_id,
    );
  }

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

  ReportLineItem copyWith({
    String? item_title,
    String? description,
    double? amount,
    bool? isIncrease,
  }) {
    return ReportLineItem(
      item_title: item_title ?? this.item_title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isIncrease: isIncrease ?? this.isIncrease,
    );
  }

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

  ReportGroup copyWith({
    String? group_title,
    List<ReportLineItem>? line_items,
    double? subtotal,
  }) {
    return ReportGroup(
      group_title: group_title ?? this.group_title,
      line_items: line_items ?? this.line_items,
      subtotal: subtotal ?? this.subtotal,
    );
  }

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

  ReportSection copyWith({
    String? section_title,
    List<ReportGroup>? groups,
    double? grand_total,
  }) {
    return ReportSection(
      section_title: section_title ?? this.section_title,
      groups: groups ?? this.groups,
      grand_total: grand_total ?? this.grand_total,
    );
  }

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
