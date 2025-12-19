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

class AccountsPayableReportScreen extends StatefulWidget {
  const AccountsPayableReportScreen({super.key});

  @override
  State<AccountsPayableReportScreen> createState() =>
      _AccountsPayableReportScreenState();
}

class _AccountsPayableReportScreenState
    extends State<AccountsPayableReportScreen> {
  late AccountsPayable _report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _report = ModalRoute.of(context)!.settings.arguments as AccountsPayable;
    } catch (e) {
      _report = AccountsPayable.initial();
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
      reportType: 'accounts_payable',
      title: 'Accounts Payable Help',
      sections: [
        const HelpSection(
          title: 'What is Accounts Payable?',
          content:
              'Tracks money your business OWES to suppliers for bills received. Shows who you need to pay, how much, and if any payments are overdue.',
        ),
        const HelpSection(
          title: 'Before Generating',
          items: [
            HelpItem(text: '- Upload all supplier bills'),
            HelpItem(text: '- Set bills to "Posted" status'),
            HelpItem(text: '- Ensure document type is "Bill"'),
          ],
        ),
        const HelpSection(
          title: 'Key Information',
          items: [
            HelpItem(text: 'Total Payable: All money you owe'),
            HelpItem(text: 'Total Overdue: Bills past due date'),
            HelpItem(text: 'By Supplier: Grouped by supplier name'),
          ],
        ),
        const HelpSection(
          title: 'Payment Management',
          items: [
            HelpItem(text: '- Prioritize overdue bills'),
            HelpItem(text: '- Schedule payments before due dates'),
            HelpItem(text: '- Maintain good supplier relationships'),
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

    if (loadedReport is! AccountsPayable) {
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
            const SizedBox(height: 20),
            _buildSummarySection(loadedReport),
            const SizedBox(height: 30),
            ...loadedReport.suppliers.map(
              (supplier) => _buildSupplierSection(supplier),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(loadedReport),
            const SizedBox(height: 30),
            _buildReportFooter(loadedReport),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(AccountsPayable report) {
    final startDate =
        report.fiscal_period['startDate']?.toString().split(' ')[0] ?? 'N/A';
    final endDate =
        report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.red.shade900, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNTS PAYABLE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildSummarySection(AccountsPayable report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade900, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUMMARY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const Divider(color: Colors.red),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Payable', report.total_payable, isBold: true),
          _buildSummaryRow('Total Overdue', report.total_overdue),
          _buildSummaryRow(
            'Overdue Bill Count',
            report.overdue_bill_count.toDouble(),
            isCount: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isBold = false,
    bool isCount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            isCount ? value.toInt().toString() : _formatCurrency(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: value > 0 ? Colors.red.shade700 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection(Supplier supplier) {
    if (supplier.bills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.supplier_name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              if (supplier.supplier_contact.isNotEmpty)
                Text(
                  supplier.supplier_contact,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildBillTable(supplier.bills),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBillTable(List<AccountLineItem> bills) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            _buildTableHeader('Bill #'),
            _buildTableHeader('Date'),
            _buildTableHeader('Due Date'),
            _buildTableHeader('Amount'),
            _buildTableHeader('Status'),
          ],
        ),
        ...bills.map((bill) => _buildBillRow(bill)),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  TableRow _buildBillRow(AccountLineItem bill) {
    final isOverdue = bill.isOverdue;
    final bgColor = isOverdue ? Colors.red.shade50 : Colors.white;
    final textColor = isOverdue ? Colors.red.shade900 : Colors.black87;

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        _buildTableCell(bill.account_line_id, textColor),
        _buildTableCell(bill.date_issued.toString().split(' ')[0], textColor),
        _buildTableCell(bill.due_date.toString().split(' ')[0], textColor),
        _buildTableCell(
          _formatCurrency(bill.amount_due),
          textColor,
          align: TextAlign.right,
        ),
        _buildTableCell(
          isOverdue ? 'OVERDUE' : 'Due',
          textColor,
          bold: isOverdue,
        ),
      ],
    );
  }

  Widget _buildTableCell(
    String text,
    Color color, {
    TextAlign align = TextAlign.left,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AccountsPayable report) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleDownloadPdf(report),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red.shade700,
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

  Future<void> _handleDownloadPdf(AccountsPayable report) async {
    try {
      final pdf = await _generatePdf(report);

      Directory? directory;
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

      final directoryPath = directory?.path;
      if (directoryPath == null) {
        throw Exception('Could not access storage directory');
      }

      final fileName =
          'AccountsPayable_${report.report_id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

  Future<void> _handleShare(AccountsPayable report) async {
    try {
      final pdf = await _generatePdf(report);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/accounts_payable_${report.report_id}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      final params = ShareParams(
        files: [XFile(file.path)],
        text: 'Accounts Payable Report - ${report.report_id}',
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

  Future<pw.Document> _generatePdf(AccountsPayable report) async {
    final pdf = pw.Document();
    final asOfDate =
        report.fiscal_period['endDate']?.toString().split(' ')[0] ?? 'N/A';

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
                    bottom: pw.BorderSide(color: PdfColors.red900, width: 3),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ACCOUNTS PAYABLE',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
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
                  border: pw.Border.all(color: PdfColors.red900),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    _buildPdfSummaryRow(
                      'Total Payable',
                      _formatCurrency(report.total_payable),
                    ),
                    _buildPdfSummaryRow(
                      'Total Overdue',
                      _formatCurrency(report.total_overdue),
                    ),
                    _buildPdfSummaryRow(
                      'Overdue Bill Count',
                      report.overdue_bill_count.toString(),
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

  pw.Widget _buildPdfSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label), pw.Text(value)],
      ),
    );
  }

  Widget _buildReportFooter(AccountsPayable report) {
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
