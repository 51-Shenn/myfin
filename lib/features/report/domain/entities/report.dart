import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/report/services/generator/acc_payable_generator.dart';
import 'package:myfin/features/report/services/generator/acc_receivable_generator.dart';
import 'package:myfin/features/report/services/generator/balance_sheet_generator.dart';
import 'package:myfin/features/report/services/generator/cash_flow_generator.dart';
import 'package:myfin/features/report/services/generator/profitloss_generator.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

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

  factory Report.initial() => Report(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    report_type: ReportType.profitLoss,
    member_id: '',
  );

  Future<dynamic> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    return Report.initial();
  }

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

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
    };
  }

  factory Report.fromMap(Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    Map<String, DateTime> stringToDateMap(String source) {
      final decoded = jsonDecode(source) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, DateTime.parse(value)));
    }

    return Report(
      report_id: data['report_id'] as String? ?? '',
      generated_at: toDateTime(data['generated_at']),
      fiscal_period: stringToDateMap(data['fiscal_period']),
      report_type: stringToReportType(data['report_type']),
      member_id: data['member_id'] as String? ?? '',
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
  final double total_expenses; // Total of all operating expenses
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
    required this.total_expenses,
    required this.operating_income,
    required this.income_before_tax,
    required this.income_tax_expense,
    required this.net_income,
  }) : super(report_type: ReportType.profitLoss);

  factory ProfitAndLossReport.initial() => ProfitAndLossReport(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    member_id: '',
    sections: List.empty(),
    gross_profit: 0,
    total_expenses: 0,
    operating_income: 0,
    income_before_tax: 0,
    income_tax_expense: 0,
    net_income: 0,
  );

  @override
  Future<ProfitAndLossReport> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final generator = ProfitLossGenerator();
    return await generator.generateFullReport(this, businessName, docLineData);
  }

  @override
  String toString() {
    return '${super.toString()}: '
        'Gross Profit: $gross_profit, '
        'Operating Income: $operating_income, '
        'Net Income: $net_income';
  }

  @override
  ProfitAndLossReport copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
    List<ReportSection>? sections,
    double? gross_profit,
    double? total_expenses,
    double? operating_income,
    double? income_before_tax,
    double? income_tax_expense,
    double? net_income,
  }) {
    return ProfitAndLossReport(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      member_id: member_id ?? this.member_id,
      sections: sections ?? this.sections,
      gross_profit: gross_profit ?? this.gross_profit,
      total_expenses: total_expenses ?? this.total_expenses,
      operating_income: operating_income ?? this.operating_income,
      income_before_tax: income_before_tax ?? this.income_before_tax,
      income_tax_expense: income_tax_expense ?? this.income_tax_expense,
      net_income: net_income ?? this.net_income,
    );
  }

  factory ProfitAndLossReport.fromMap(Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    Map<String, DateTime> parseFiscalPeriod(dynamic value) {
      if (value is Map) {
        return value.map(
          (key, val) => MapEntry(key.toString(), toDateTime(val)),
        );
      }
      if (value is String) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        return decoded.map((key, val) => MapEntry(key, DateTime.parse(val)));
      }
      return {'': DateTime.now()};
    }

    List<ReportSection> parseSections(dynamic value) {
      if (value is! List) return [];
      return value.map((sectionData) {
        final groups = (sectionData['groups'] as List? ?? []).map((groupData) {
          final lineItems = (groupData['line_items'] as List? ?? []).map((
            itemData,
          ) {
            return ReportLineItem(
              item_title: itemData['item_title'] as String? ?? '',
              description: itemData['description'] as String?,
              amount: (itemData['amount'] as num?)?.toDouble() ?? 0.0,
              isIncrease: itemData['isIncrease'] as bool? ?? false,
            );
          }).toList();

          return ReportGroup(
            group_title: groupData['group_title'] as String? ?? '',
            line_items: lineItems,
            subtotal: (groupData['subtotal'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        return ReportSection(
          section_title: sectionData['section_title'] as String? ?? '',
          groups: groups,
          grand_total: (sectionData['grand_total'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    return ProfitAndLossReport(
      report_id: data['report_id'] as String? ?? '',
      generated_at: toDateTime(data['generated_at']),
      fiscal_period: parseFiscalPeriod(data['fiscal_period']),
      member_id: data['member_id'] as String? ?? '',
      sections: parseSections(data['sections']),
      gross_profit: (data['gross_profit'] as num?)?.toDouble() ?? 0.0,
      total_expenses: (data['total_expenses'] as num?)?.toDouble() ?? 0.0,
      operating_income: (data['operating_income'] as num?)?.toDouble() ?? 0.0,
      income_before_tax: (data['income_before_tax'] as num?)?.toDouble() ?? 0.0,
      income_tax_expense:
          (data['income_tax_expense'] as num?)?.toDouble() ?? 0.0,
      net_income: (data['net_income'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
      'sections': sections
          .map(
            (section) => {
              'section_title': section.section_title,
              'grand_total': section.grand_total,
              'groups': section.groups
                  .map(
                    (group) => {
                      'group_title': group.group_title,
                      'subtotal': group.subtotal,
                      'line_items': group.line_items
                          .map(
                            (item) => {
                              'item_title': item.item_title,
                              'description': item.description,
                              'amount': item.amount,
                              'isIncrease': item.isIncrease,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'gross_profit': gross_profit,
      'total_expenses': total_expenses,
      'operating_income': operating_income,
      'income_before_tax': income_before_tax,
      'income_tax_expense': income_tax_expense,
      'net_income': net_income,
    };
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
  }) : super(report_type: ReportType.cashFlow);

  factory CashFlowStatement.initial() => CashFlowStatement(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    member_id: '',
    sections: List.empty(),
    total_operating_cash_flow: 0,
    total_investing_cash_flow: 0,
    total_financing_cash_flow: 0,
    cash_balance: 0,
  );

  @override
  Future<CashFlowStatement> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final generator = CashFlowGenerator();
    return await generator.generateFullReport(
      this,
      businessName,
      docData,
      docLineData,
    );
  }

  @override
  String toString() {
    return '${super.toString()}: '
        'Total Operating Cash Flow: $total_operating_cash_flow, '
        'Total Investing Cash Flow: $total_investing_cash_flow, '
        'Total Financing Cash Flow: $total_financing_cash_flow, '
        'Cash Balance: $cash_balance';
  }

  factory CashFlowStatement.fromMap(Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    Map<String, DateTime> parseFiscalPeriod(dynamic value) {
      if (value is Map) {
        return value.map(
          (key, val) => MapEntry(key.toString(), toDateTime(val)),
        );
      }
      if (value is String) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        return decoded.map((key, val) => MapEntry(key, DateTime.parse(val)));
      }
      return {'': DateTime.now()};
    }

    List<ReportSection> parseSections(dynamic value) {
      if (value is! List) return [];
      return value.map((sectionData) {
        final groups = (sectionData['groups'] as List? ?? []).map((groupData) {
          final lineItems = (groupData['line_items'] as List? ?? []).map((
            itemData,
          ) {
            return ReportLineItem(
              item_title: itemData['item_title'] as String? ?? '',
              description: itemData['description'] as String?,
              amount: (itemData['amount'] as num?)?.toDouble() ?? 0.0,
              isIncrease: itemData['isIncrease'] as bool? ?? false,
            );
          }).toList();

          return ReportGroup(
            group_title: groupData['group_title'] as String? ?? '',
            line_items: lineItems,
            subtotal: (groupData['subtotal'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        return ReportSection(
          section_title: sectionData['section_title'] as String? ?? '',
          groups: groups,
          grand_total: (sectionData['grand_total'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    return CashFlowStatement(
      report_id: data['report_id'] as String? ?? '',
      generated_at: toDateTime(data['generated_at']),
      fiscal_period: parseFiscalPeriod(data['fiscal_period']),
      member_id: data['member_id'] as String? ?? '',
      sections: parseSections(data['sections']),
      total_operating_cash_flow:
          (data['total_operating_cash_flow'] as num?)?.toDouble() ?? 0.0,
      total_investing_cash_flow:
          (data['total_investing_cash_flow'] as num?)?.toDouble() ?? 0.0,
      total_financing_cash_flow:
          (data['total_financing_cash_flow'] as num?)?.toDouble() ?? 0.0,
      cash_balance: (data['cash_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
      'sections': sections
          .map(
            (section) => {
              'section_title': section.section_title,
              'grand_total': section.grand_total,
              'groups': section.groups
                  .map(
                    (group) => {
                      'group_title': group.group_title,
                      'subtotal': group.subtotal,
                      'line_items': group.line_items
                          .map(
                            (item) => {
                              'item_title': item.item_title,
                              'description': item.description,
                              'amount': item.amount,
                              'isIncrease': item.isIncrease,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'total_operating_cash_flow': total_operating_cash_flow,
      'total_investing_cash_flow': total_investing_cash_flow,
      'total_financing_cash_flow': total_financing_cash_flow,
      'cash_balance': cash_balance,
    };
  }

  @override
  CashFlowStatement copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
    List<ReportSection>? sections,
    double? total_operating_cash_flow,
    double? total_investing_cash_flow,
    double? total_financing_cash_flow,
    double? cash_balance,
  }) {
    return CashFlowStatement(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      member_id: member_id ?? this.member_id,
      sections: sections ?? this.sections,
      total_operating_cash_flow:
          total_operating_cash_flow ?? this.total_operating_cash_flow,
      total_investing_cash_flow:
          total_investing_cash_flow ?? this.total_investing_cash_flow,
      total_financing_cash_flow:
          total_financing_cash_flow ?? this.total_financing_cash_flow,
      cash_balance: cash_balance ?? this.cash_balance,
    );
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
  }) : super(report_type: ReportType.balanceSheet);

  factory BalanceSheet.initial() => BalanceSheet(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    member_id: '',
    sections: List.empty(),
    total_assets: 0,
    total_liabilities: 0,
    total_equity: 0,
    total_liabilities_and_equity: 0,
  );

  @override
  Future<BalanceSheet> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final generator = BalanceSheetGenerator();
    return await generator.generateFullReport(
      this,
      businessName,
      docData,
      docLineData,
    );
  }

  @override
  String toString() {
    return '${super.toString()}: '
        'Total Assets: $total_assets, '
        'Total Liabilities: $total_liabilities, '
        'Total Equity: $total_equity, '
        'Total Liabilities + Equity: $total_liabilities_and_equity';
  }

  factory BalanceSheet.fromMap(Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    Map<String, DateTime> parseFiscalPeriod(dynamic value) {
      if (value is Map) {
        return value.map(
          (key, val) => MapEntry(key.toString(), toDateTime(val)),
        );
      }
      if (value is String) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        return decoded.map((key, val) => MapEntry(key, DateTime.parse(val)));
      }
      return {'': DateTime.now()};
    }

    List<ReportSection> parseSections(dynamic value) {
      if (value is! List) return [];
      return value.map((sectionData) {
        final groups = (sectionData['groups'] as List? ?? []).map((groupData) {
          final lineItems = (groupData['line_items'] as List? ?? []).map((
            itemData,
          ) {
            return ReportLineItem(
              item_title: itemData['item_title'] as String? ?? '',
              description: itemData['description'] as String?,
              amount: (itemData['amount'] as num?)?.toDouble() ?? 0.0,
              isIncrease: itemData['isIncrease'] as bool? ?? false,
            );
          }).toList();

          return ReportGroup(
            group_title: groupData['group_title'] as String? ?? '',
            line_items: lineItems,
            subtotal: (groupData['subtotal'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        return ReportSection(
          section_title: sectionData['section_title'] as String? ?? '',
          groups: groups,
          grand_total: (sectionData['grand_total'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    return BalanceSheet(
      report_id: data['report_id'] as String? ?? '',
      generated_at: toDateTime(data['generated_at']),
      fiscal_period: parseFiscalPeriod(data['fiscal_period']),
      member_id: data['member_id'] as String? ?? '',
      sections: parseSections(data['sections']),
      total_assets: (data['total_assets'] as num?)?.toDouble() ?? 0.0,
      total_liabilities: (data['total_liabilities'] as num?)?.toDouble() ?? 0.0,
      total_equity: (data['total_equity'] as num?)?.toDouble() ?? 0.0,
      total_liabilities_and_equity:
          (data['total_liabilities_and_equity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
      'sections': sections
          .map(
            (section) => {
              'section_title': section.section_title,
              'grand_total': section.grand_total,
              'groups': section.groups
                  .map(
                    (group) => {
                      'group_title': group.group_title,
                      'subtotal': group.subtotal,
                      'line_items': group.line_items
                          .map(
                            (item) => {
                              'item_title': item.item_title,
                              'description': item.description,
                              'amount': item.amount,
                              'isIncrease': item.isIncrease,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'total_assets': total_assets,
      'total_liabilities': total_liabilities,
      'total_equity': total_equity,
      'total_liabilities_and_equity': total_liabilities_and_equity,
    };
  }

  @override
  BalanceSheet copyWith({
    String? report_id,
    DateTime? generated_at,
    Map<String, DateTime>? fiscal_period,
    ReportType? report_type,
    String? member_id,
    List<ReportSection>? sections,
    double? total_assets,
    double? total_liabilities,
    double? total_equity,
    double? total_liabilities_and_equity,
  }) {
    return BalanceSheet(
      report_id: report_id ?? this.report_id,
      generated_at: generated_at ?? this.generated_at,
      fiscal_period: fiscal_period ?? this.fiscal_period,
      member_id: member_id ?? this.member_id,
      sections: sections ?? this.sections,
      total_assets: total_assets ?? this.total_assets,
      total_liabilities: total_liabilities ?? this.total_liabilities,
      total_equity: total_equity ?? this.total_equity,
      total_liabilities_and_equity:
          total_liabilities_and_equity ?? this.total_liabilities_and_equity,
    );
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
    required super.member_id,
    required this.customers,
    required this.total_receivable,
    required this.total_overdue,
    required this.overdue_invoice_count,
  }) : super(report_type: ReportType.accountsReceivable);

  factory AccountsReceivable.initial() => AccountsReceivable(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    member_id: '',
    customers: List.empty(),
    total_receivable: 0,
    total_overdue: 0,
    overdue_invoice_count: 0,
  );

  @override
  Future<AccountsReceivable> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final generator = AccReceivableGenerator();
    return await generator.generateFullReport(
      this,
      businessName,
      docData,
      docLineData,
    );
  }

  @override
  String toString() {
    return '${super.toString()}: '
        'Total Receivable: $total_receivable, '
        'Total Overdue: $total_overdue, '
        'Overdue Invoice Count: $overdue_invoice_count';
  }

  factory AccountsReceivable.fromMap(Map<String, dynamic> data) {
    return AccountsReceivable(
      report_id: data['report_id'] as String? ?? '',
      generated_at: data['generated_at'] is Timestamp
          ? (data['generated_at'] as Timestamp).toDate()
          : DateTime.now(),
      fiscal_period: {'': DateTime.now()}, // Simplified for now
      member_id: data['member_id'] as String? ?? '',
      customers: [], // Simplified for now
      total_receivable: (data['total_receivable'] as num?)?.toDouble() ?? 0.0,
      total_overdue: (data['total_overdue'] as num?)?.toDouble() ?? 0.0,
      overdue_invoice_count: (data['overdue_invoice_count'] as int?) ?? 0,
    );
  }

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
      member_id: member_id ?? this.member_id,
      customers: customers ?? this.customers,
      total_receivable: total_receivable ?? this.total_receivable,
      total_overdue: total_overdue ?? this.total_overdue,
      overdue_invoice_count:
          overdue_invoice_count ?? this.overdue_invoice_count,
    );
  }

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
      'customers': customers
          .map(
            (customer) => {
              'customer_name': customer.customer_name,
              'customer_contact': customer.customer_contact,
              'invoices': customer.invoices
                  .map(
                    (invoice) => {
                      'account_line_id': invoice.account_line_id,
                      'date_issued': invoice.date_issued.toIso8601String(),
                      'due_date': invoice.due_date.toIso8601String(),
                      'amount_due': invoice.amount_due,
                      'isReceivable': invoice.isReceivable,
                      'isOverdue': invoice.isOverdue,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'total_receivable': total_receivable,
      'total_overdue': total_overdue,
      'overdue_invoice_count': overdue_invoice_count,
    };
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
    required super.member_id,
    required this.suppliers,
    required this.total_payable,
    required this.total_overdue,
    required this.overdue_bill_count,
  }) : super(report_type: ReportType.accountsPayable);

  factory AccountsPayable.initial() => AccountsPayable(
    report_id: '',
    generated_at: DateTime.now(),
    fiscal_period: {'': DateTime.now()},
    member_id: '',
    suppliers: List.empty(),
    total_payable: 0,
    total_overdue: 0,
    overdue_bill_count: 0,
  );

  @override
  Future<AccountsPayable> generateReport(
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final generator = AccPayableGenerator();
    return await generator.generateFullReport(
      this,
      businessName,
      docData,
      docLineData,
    );
  }

  @override
  String toString() {
    return '${super.toString()}: '
        'Total Payable: $total_payable, '
        'Total Overdue: $total_overdue, '
        'Overdue Bill Count: $overdue_bill_count';
  }

  factory AccountsPayable.fromMap(Map<String, dynamic> data) {
    return AccountsPayable(
      report_id: data['report_id'] as String? ?? '',
      generated_at: data['generated_at'] is Timestamp
          ? (data['generated_at'] as Timestamp).toDate()
          : DateTime.now(),
      fiscal_period: {'': DateTime.now()}, // Simplified for now
      member_id: data['member_id'] as String? ?? '',
      suppliers: [], // Simplified for now
      total_payable: (data['total_payable'] as num?)?.toDouble() ?? 0.0,
      total_overdue: (data['total_overdue'] as num?)?.toDouble() ?? 0.0,
      overdue_bill_count: (data['overdue_bill_count'] as int?) ?? 0,
    );
  }

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
      member_id: member_id ?? this.member_id,
      suppliers: suppliers ?? this.suppliers,
      total_payable: total_payable ?? this.total_payable,
      total_overdue: total_overdue ?? this.total_overdue,
      overdue_bill_count: overdue_bill_count ?? this.overdue_bill_count,
    );
  }

  Map<String, dynamic> toMap() {
    String dateMapToString(Map<String, DateTime> map) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      return jsonEncode(encodedMap);
    }

    return {
      'report_id': report_id,
      'generated_at': generated_at,
      'fiscal_period': dateMapToString(fiscal_period),
      'report_type': report_type.reportTypeToString,
      'member_id': member_id,
      'suppliers': suppliers
          .map(
            (supplier) => {
              'supplier_name': supplier.supplier_name,
              'supplier_contact': supplier.supplier_contact,
              'bills': supplier.bills
                  .map(
                    (bill) => {
                      'account_line_id': bill.account_line_id,
                      'date_issued': bill.date_issued.toIso8601String(),
                      'due_date': bill.due_date.toIso8601String(),
                      'amount_due': bill.amount_due,
                      'isReceivable': bill.isReceivable,
                      'isOverdue': bill.isOverdue,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'total_payable': total_payable,
      'total_overdue': total_overdue,
      'overdue_bill_count': overdue_bill_count,
    };
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
