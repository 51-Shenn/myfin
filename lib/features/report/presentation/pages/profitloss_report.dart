import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ProfitAndLossReportScreen extends StatefulWidget {
  const ProfitAndLossReportScreen({super.key});

  @override
  State<ProfitAndLossReportScreen> createState() =>
      _ProfitAndLossReportScreenState();
}

class _ProfitAndLossReportScreenState extends State<ProfitAndLossReportScreen> {
  ProfitAndLossReport profitAndLossReport = ProfitAndLossReport.initial();

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    profitAndLossReport =
        ModalRoute.of(context)!.settings.arguments as ProfitAndLossReport;
    ProfitAndLossReport report = profitAndLossReport.copyWith(
      sections: [
        ReportSection(
          section_title: 'Revenue',
          grand_total: 14000,
          groups: [
            ReportGroup(
              group_title: 'Operating Revenue',
              subtotal: 15000,
              line_items: [
                ReportLineItem(
                  item_title: 'Sales Revenue',
                  amount: 13000,
                  isIncrease: true,
                ),
                ReportLineItem(
                  item_title: 'Service Revenue',
                  amount: 2000,
                  isIncrease: true,
                ),
              ],
            ),
            ReportGroup(
              group_title: 'Deductions from Revenue',
              subtotal: -1000,
              line_items: [
                ReportLineItem(
                  item_title: 'Sales Returns     ',
                  amount: 1000,
                  isIncrease: false,
                ),
              ],
            ),
          ],
        ),
        ReportSection(
          section_title: 'Cost of Goods Sold',
          grand_total: -4000,
          groups: [
            ReportGroup(
              group_title: 'Opening Inventory',
              line_items: [],
              subtotal: -4000,
            ),
          ],
        ),
        ReportSection(
          section_title: 'Operating Expenses',
          grand_total: -1000,
          groups: [
            ReportGroup(
              group_title: 'Selling & Marketing Expenses',
              line_items: [
                ReportLineItem(
                  item_title: 'Advertising         ',
                  amount: 1000,
                  isIncrease: false,
                ),
              ],
              subtotal: -1000,
            ),
          ],
        ),
      ],
      gross_profit: 10000,
      operating_income: 9000,
      income_before_tax: 9000,
      income_tax_expense: -1000,
      net_income: 8000,
    );

    return BlocProvider(
      create: (_) =>
          ReportBLoC(ReportRepository())..add(LoadReportDetailsEvent(report)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              NavBarController.of(context)?.toggleNavBar();
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.attach_file, color: Colors.black, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Reports',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocListener<ReportBLoC, ReportState>(
          listener: (context, state) {
            if (state.error != null && mounted) {
              _showErrorSnackBar(context, state.error!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ReportBLoC>().add(ClearErrorEvent());
                }
              });
            }
          },
          child: BlocBuilder<ReportBLoC, ReportState>(
            builder: (context, state) {
              if (state.loadingReports && state.loadedReports.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Header
                      _buildReportHeader(report),
                      const SizedBox(height: 12),

                      // Report Sections
                      ...report.sections.map(
                        (section) => _buildReportSection(section),
                      ),

                      const SizedBox(height: 30),

                      // Financial Summary
                      _buildFinancialSummary(report),

                      const SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(context, report),

                      const SizedBox(height: 30),

                      // Report Footer
                      _buildReportFooter(report),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build Report Header Section
  Widget _buildReportHeader(ProfitAndLossReport report) {
    final startDate =
        report.fiscal_period['startDate']?.toString().split(' ')[0] ?? 'N/A';
    final endDate =
        report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade900, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROFIT & LOSS STATEMENT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period: $startDate to $endDate',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              Text(
                'Report ID: ${report.report_id}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Individual Report Section with Groups and Line Items
  Widget _buildReportSection(ReportSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: Text(
            section.section_title.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Groups within section
        ...section.groups.map((group) => _buildReportGroup(group)),

        if (section.groups.first.line_items.isEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 35.0,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
              columnSpacing: 100,
              columns: [
                DataColumn(
                  label: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Amount(RM)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              rows: section.groups
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(item.group_title),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(
                                _formatCurrency(item.subtotal),
                                style: TextStyle(
                                  color: () {
                                    if (item.subtotal > 0) return Colors.green;
                                    if (item.subtotal < 0) return Colors.red;
                                    return Colors.grey; // for zero
                                  }(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),

        if (section.groups.first.line_items.isEmpty)
          const SizedBox(height: 24),

        // Section Total
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              top: BorderSide(color: Colors.grey.shade800, width: 2),
              bottom: BorderSide(color: Colors.grey.shade800, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ${section.section_title}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(section.grand_total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build Group with Line Items Table
  Widget _buildReportGroup(ReportGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Title
        if (group.line_items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 12, bottom: 8),
            child: Text(
              group.group_title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

        // Line Items Table
        if (group.line_items.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 35.0,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
              columnSpacing: 100,
              columns: [
                DataColumn(
                  label: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Amount(RM)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              rows: group.line_items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(item.item_title),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(
                                _formatCurrency(item.amount),
                                style: TextStyle(
                                  color: item.isIncrease
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),

        // Group Subtotal
        if (group.line_items.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade400)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ${group.group_title}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  _formatCurrency(group.subtotal),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build Financial Summary Box
  Widget _buildFinancialSummary(ProfitAndLossReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade900, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCIAL SUMMARY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const Divider(color: Colors.blue),
          const SizedBox(height: 8),
          _buildMetricRow('Gross Profit', report.gross_profit),
          _buildMetricRow('Operating Income', report.operating_income),
          _buildMetricRow('Income Before Tax', report.income_before_tax),
          _buildMetricRow('Income Tax Expense', report.income_tax_expense),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.blue.shade900, thickness: 2),
          ),
          _buildMetricRow('NET INCOME', report.net_income, isFinal: true),
        ],
      ),
    );
  }

  /// Build Metric Row for Summary
  Widget _buildMetricRow(String label, double value, {bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 15 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: isFinal ? 15 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              color: value >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Action Buttons
  Widget _buildActionButtons(BuildContext context, ProfitAndLossReport report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF Download initiated')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF Share initiated')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build Report Footer
  Widget _buildReportFooter(ProfitAndLossReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Generated on ${DateTime.now().toString().split('.')[0]}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'Report Type: ${report.report_type.reportTypeToString}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Format currency values
  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toStringAsFixed(2);
    return isNegative ? '($absAmount)' : absAmount;
  }
}
