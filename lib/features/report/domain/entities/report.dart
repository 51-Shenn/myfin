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

// report invoice line
class AccountLineItem extends Equatable {
  final String account_line_id;
  final DateTime date_issued;
  final DateTime due_date;
  final double amount_due;
  final bool isReceivable;
  final bool isOverdue;

  const AccountLineItem({
    required this.account_line_id,
    required this.date_issued,
    required this.due_date,
    required this.amount_due,
    required this.isReceivable,
    this.isOverdue = false,
  });

  AccountLineItem copyWith({
    String? account_line_id,
    DateTime? date_issued,
    DateTime? due_date,
    double? amount_due,
    bool? isReceivable,
    bool? isOverdue,
  }) {
    return AccountLineItem(
      account_line_id: account_line_id ?? this.account_line_id,
      date_issued: date_issued ?? this.date_issued,
      due_date: due_date ?? this.due_date,
      amount_due: amount_due ?? this.amount_due,
      isReceivable: isReceivable ?? this.isReceivable,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }

  @override
  List<Object> get props => [
    account_line_id,
    date_issued,
    due_date,
    amount_due,
    isReceivable,
    isOverdue,
  ];
}

// customer model for receivables
class Customer extends Equatable {
  final String customer_name;
  final String customer_contact;
  final List<AccountLineItem> invoices;

  const Customer({
    required this.customer_name,
    required this.customer_contact,
    required this.invoices,
  });

  Customer copyWith({
    String? customer_name,
    String? customer_contact,
    List<AccountLineItem>? invoices,
  }) {
    return Customer(
      customer_name: customer_name ?? this.customer_name,
      customer_contact: customer_contact ?? this.customer_contact,
      invoices: invoices ?? this.invoices,
    );
  }

  @override
  List<Object> get props => [customer_name, customer_contact, invoices];
}

// supplier model for payables
class Supplier extends Equatable {
  final String supplier_name;
  final String supplier_contact;
  final List<AccountLineItem> bills;

  const Supplier({
    required this.supplier_name,
    required this.supplier_contact,
    required this.bills,
  });

  Supplier copyWith({
    String? supplier_name,
    String? email,
    String? supplier_contact,
    List<AccountLineItem>? bills,
  }) {
    return Supplier(
      supplier_name: supplier_name ?? this.supplier_name,
      supplier_contact: supplier_contact ?? this.supplier_contact,
      bills: bills ?? this.bills,
    );
  }

  @override
  List<Object> get props => [supplier_name, supplier_contact, bills];
}

// accounts receivable entity
class AccountsReceivable extends Report {
  final List<Customer> customers;
  final double total_receivable;
  final double total_overdue;
  final int overdue_invoice_count;

  const AccountsReceivable({
    required super.report_id,
    required super.generated_at,
    required super.fiscal_period,
    required super.report_type,
    required super.member_id,
    required this.customers,
    required this.total_receivable,
    required this.total_overdue,
    required this.overdue_invoice_count,
  });

  @override
  AccountsReceivable copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
    List<Customer>? customers,
    double? total_receivable,
    double? total_overdue,
    int? overdue_invoice_count,
  }) {
    return AccountsReceivable(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      report_type: report_type ?? this.report_type,
      member_id: member_id ?? this.member_id,
      customers: customers ?? this.customers,
      total_receivable: total_receivable ?? this.total_receivable,
      total_overdue: total_overdue ?? this.total_overdue,
      overdue_invoice_count:
          overdue_invoice_count ?? this.overdue_invoice_count,
    );
  }

  @override
  List<Object> get props => [
    ...super.props,
    customers,
    total_receivable,
    total_overdue,
    overdue_invoice_count,
  ];
}

// accounts payable entity
class AccountsPayable extends Report {
  final List<Supplier> suppliers;
  final double total_payable;
  final double total_overdue;
  final int overdue_bill_count;

  const AccountsPayable({
    required super.report_id,
    required super.generated_at,
    required super.fiscal_period,
    required super.report_type,
    required super.member_id,
    required this.suppliers,
    required this.total_payable,
    required this.total_overdue,
    required this.overdue_bill_count,
  });

  @override
  AccountsPayable copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
    List<Supplier>? suppliers,
    double? total_payable,
    double? total_overdue,
    int? overdue_bill_count,
  }) {
    return AccountsPayable(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      report_type: report_type ?? this.report_type,
      member_id: member_id ?? this.member_id,
      suppliers: suppliers ?? this.suppliers,
      total_payable: total_payable ?? this.total_payable,
      total_overdue: total_overdue ?? this.total_overdue,
      overdue_bill_count: overdue_bill_count ?? this.overdue_bill_count,
    );
  }

  @override
  List<Object> get props => [
    ...super.props,
    suppliers,
    total_payable,
    total_overdue,
    overdue_bill_count,
  ];
}
