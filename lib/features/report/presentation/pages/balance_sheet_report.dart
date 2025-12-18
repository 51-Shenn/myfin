import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';
import 'package:myfin/features/report/presentation/widgets/help_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BalanceSheetReportScreen extends StatefulWidget {
  const BalanceSheetReportScreen({super.key});

  @override
  State<BalanceSheetReportScreen> createState() =>
      _BalanceSheetReportScreenState();
}

class _BalanceSheetReportScreenState extends State<BalanceSheetReportScreen> {
  late BalanceSheet _report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _report = ModalRoute.of(context)!.settings.arguments as BalanceSheet;
    } catch (e) {
      _report = BalanceSheet.initial();
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
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.black),
          onPressed: _showHelpDialog,
          tooltip: 'Help',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    ReportHelpDialog.show(
      context,
      reportType: 'balance_sheet',
      title: 'Balance Sheet Help',
      sections: [
        const HelpSection(
          title: '📊 What is a Balance Sheet?',
          content:
              'A Balance Sheet shows your financial position at a specific point in time. It must follow the equation: Assets = Liabilities + Equity',
        ),
        const HelpSection(
          title: 'Before Generating',
          items: [
            HelpItem(
              text:
                  '- Upload all relevant documents (invoices, receipts, etc.)',
            ),
            HelpItem(text: '- Ensure all documents are in "Posted" status'),
            HelpItem(text: '- Assign category codes to all line items'),
          ],
        ),
        const HelpSection(
          title: 'Report Generation Order',
          content:
              'For accurate balance sheets, generate reports in this order:',
          items: [
            HelpItem(text: '1. Profit & Loss Report (first)'),
            HelpItem(text: '2. Cash Flow Statement (second)'),
            HelpItem(text: '3. Balance Sheet (last)'),
          ],
        ),
        const HelpSection(
          title: 'Balance Sheet Not Balancing?',
          items: [
            HelpItem(
              icon: '•',
              text: 'Generate P&L and Cash Flow reports first',
            ),
            HelpItem(icon: '•', text: 'Check all documents are "Posted"'),
            HelpItem(icon: '•', text: 'Verify date ranges match'),
            HelpItem(
              icon: '•',
              text: 'Ensure all transactions have categories',
            ),
          ],
        ),
      ],
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
    if (state.loadingReportDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    final loadedReport = state.loadedReportDetails;

    if (loadedReport is! BalanceSheet) {
      return const Center(
        child: Text(
          'Invalid report type or report not loaded',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(loadedReport),
            const SizedBox(height: 12),
            ...loadedReport.sections.map(_buildReportSection),
            const SizedBox(height: 30),
            _buildFinancialSummary(loadedReport),
            const SizedBox(height: 20),
            _buildActionButtons(loadedReport),
            const SizedBox(height: 30),
            _buildReportFooter(loadedReport),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(BalanceSheet report) {
    final asOfDate =
        report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.purple.shade900, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE SHEET',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'As of $asOfDate',
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
        color: Colors.purple.shade100,
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.purple.shade900,
        ),
      ),
    );
  }

  Widget _buildGroupSummaryTable(List<ReportGroup> groups) {
    final nonZeroGroups = groups
        .where((group) => group.subtotal.abs() >= 0.005)
        .toList();
    if (nonZeroGroups.isEmpty) return const SizedBox.shrink();

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Amount (RM)',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        ...nonZeroGroups.map(
          (group) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(group.group_title),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _formatCurrency(group.subtotal),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

    final nonZeroItems = group.line_items
        .where((item) => item.amount.abs() >= 0.005)
        .toList();
    if (nonZeroItems.isEmpty) return const SizedBox.shrink();

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
    final filteredItems = lineItems
        .where((item) => item.amount.abs() >= 0.005)
        .toList();
    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Amount (RM)',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        ...filteredItems.map(
          (item) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(item.item_title),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _formatCurrency(item.amount),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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

  Widget _buildFinancialSummary(BalanceSheet report) {
    final isBalanced =
        (report.total_assets - report.total_liabilities_and_equity).abs() <
        0.01;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border.all(color: Colors.purple.shade900, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE SHEET EQUATION',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
          const Divider(color: Colors.purple),
          const SizedBox(height: 8),
          _buildMetricRow('Total Assets', report.total_assets),
          const SizedBox(height: 12),
          _buildMetricRow('Total Liabilities', report.total_liabilities),
          _buildMetricRow('Total Equity', report.total_equity),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.purple.shade900, thickness: 2),
          ),
          _buildMetricRow(
            'Total Liabilities + Equity',
            report.total_liabilities_and_equity,
            isFinal: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isBalanced ? Icons.check_circle : Icons.error,
                color: isBalanced ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isBalanced
                    ? 'Balance Sheet Equation Verified ✓'
                    : 'Balance Sheet Does Not Balance! \nHelp in top right corner.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBalanced ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BalanceSheet report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleDownloadPdf(report),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleShare(report),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDownloadPdf(BalanceSheet report) async {
    try {
      final pdf = await _generatePdf(report);

      Directory? directory;
      String? directoryPath;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      directoryPath = directory?.path;

      if (directoryPath == null) {
        throw Exception('Could not access storage directory');
      }

      final fileName =
          'BalanceSheet_${report.report_id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('$directoryPath/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF saved to ${Platform.isAndroid ? "Downloads" : "Documents"} folder\n$fileName',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleShare(BalanceSheet report) async {
    try {
      final pdf = await _generatePdf(report);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/balance_sheet_${report.report_id}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      final params = ShareParams(
        files: [XFile(file.path)],
        text: 'Balance Sheet - ${report.report_id}',
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf(BalanceSheet report) async {
    final pdf = pw.Document();
    final asOfDate =
        report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';
    final isBalanced =
        (report.total_assets - report.total_liabilities_and_equity).abs() <
        0.01;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.purple900, width: 3),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BALANCE SHEET',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text('As of $asOfDate'),
                    pw.Text('Report ID: ${report.report_id}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.purple900),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BALANCE SHEET EQUATION',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow(
                      'Total Assets',
                      report.total_assets,
                      isBold: true,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow(
                      'Total Liabilities',
                      report.total_liabilities,
                    ),
                    _buildPdfMetricRow('Total Equity', report.total_equity),
                    pw.Divider(thickness: 2),
                    _buildPdfMetricRow(
                      'Total Liabilities + Equity',
                      report.total_liabilities_and_equity,
                      isBold: true,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      isBalanced
                          ? 'Balance Sheet Equation Verified ✓'
                          : 'Balance Sheet Does Not Balance!',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Help in top right corner.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfMetricRow(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            _formatCurrency(value),
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportFooter(BalanceSheet report) {
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

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toStringAsFixed(2);
    return isNegative ? '($absAmount)' : absAmount;
  }
}
