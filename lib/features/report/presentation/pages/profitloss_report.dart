import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
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
  late ProfitAndLossReport _report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _report =
          ModalRoute.of(context)!.settings.arguments as ProfitAndLossReport;
    } catch (e) {
      _report = ProfitAndLossReport.initial();
      _showErrorSnackBar('Failed to retrieve report details: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportBLoC(context.read<ReportRepository>())
            ..add(LoadReportDetailsEvent(_report)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: BlocListener<ReportBLoC, ReportState>(
          listener: _handleBlocStateChanges,
          child: BlocBuilder<ReportBLoC, ReportState>(builder: _buildBody),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pop(context);
        },
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, color: Colors.black, size: 28),
          SizedBox(width: 8),
          Text(
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
    );
  }

  void _handleBlocStateChanges(BuildContext context, ReportState state) {
    if (state.error != null && mounted) {
      _showErrorSnackBar(state.error!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ReportBLoC>().add(ClearErrorEvent());
        }
      });
    }
  }

  Widget _buildBody(BuildContext context, ReportState state) {
    if (state.loadingReports && state.loadedReports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 12),
            ..._report.sections.map(_buildReportSection),
            const SizedBox(height: 30),
            _buildFinancialSummary(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 30),
            _buildReportFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    final startDate =
        _report.fiscal_period['startDate']?.toString().split(' ')[0] ?? 'N/A';
    final endDate =
        _report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';

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
            children: [
              Text(
                'Period: $startDate to $endDate',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              Text(
                'Report ID: ${_report.report_id}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(ReportSection section) {
    final hasLineItems = section.groups.first.line_items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section.section_title),
        const SizedBox(height: 12),
        if (hasLineItems)
          ...section.groups.map(_buildReportGroup)
        else
          _buildGroupSummaryTable(section.groups),
        if (!hasLineItems) const SizedBox(height: 24),
        _buildSectionTotal(section),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _buildGroupSummaryTable(List<ReportGroup> groups) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 35.0,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
        columnSpacing: 100,
        columns: _buildTableColumns(),
        rows: groups.map(_buildGroupSummaryRow).toList(),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    return [
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
    ];
  }

  DataRow _buildGroupSummaryRow(ReportGroup group) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(group.group_title),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                _formatCurrency(group.subtotal),
                style: TextStyle(
                  color: _getAmountColor(group.subtotal),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAmountColor(double amount) {
    if (amount > 0) return Colors.green;
    if (amount < 0) return Colors.red;
    return Colors.grey;
  }

  Widget _buildSectionTotal(ReportSection section) {
    return Container(
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            _formatCurrency(section.grand_total),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGroup(ReportGroup group) {
    if (group.line_items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildLineItemsTable(group.line_items),
        _buildGroupSubtotal(group),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLineItemsTable(List<ReportLineItem> lineItems) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 35.0,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
        columnSpacing: 100,
        columns: _buildTableColumns(),
        rows: lineItems.map(_buildLineItemRow).toList(),
      ),
    );
  }

  DataRow _buildLineItemRow(ReportLineItem item) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(item.item_title),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                _formatCurrency(item.amount),
                style: TextStyle(
                  color: item.isIncrease ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSubtotal(ReportGroup group) {
    return Container(
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
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
          _buildMetricRow('Gross Profit', _report.gross_profit),
          _buildMetricRow('Operating Income', _report.operating_income),
          _buildMetricRow('Income Before Tax', _report.income_before_tax),
          _buildMetricRow('Income Tax Expense', _report.income_tax_expense),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.blue.shade900, thickness: 2),
          ),
          _buildMetricRow('NET INCOME', _report.net_income, isFinal: true),
        ],
      ),
    );
  }

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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleDownloadPdf,
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
            onPressed: _handleShare,
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

  void _handleDownloadPdf() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDF Download initiated')));
  }

  void _handleShare() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDF Share initiated')));
  }

  Widget _buildReportFooter() {
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
            'Report Type: ${_report.report_type.reportTypeToString}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toStringAsFixed(2);
    return isNegative ? '($absAmount)' : absAmount;
  }
}
