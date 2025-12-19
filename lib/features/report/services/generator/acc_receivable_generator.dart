import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/acc_receivable_calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Generator class for creating Accounts Receivable Report
class AccReceivableGenerator {
  Future<AccountsReceivable> generateFullReport(
    AccountsReceivable report,
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final asOfDate = report.fiscal_period['endDate']!;

    final calculator = AccountsReceivableCalculator(
      documents: docData,
      lineItems: docLineData,
      asOfDate: asOfDate,
    );

    // Group documents by member ID
    final groupedByMember = calculator.groupByMemberId();
    final customers = <Customer>[];

    // Build customer list
    for (var entry in groupedByMember.entries) {
      final docs = entry.value;

      // Extract customer details from first document's metadata
      String customerName = '';
      String customerContact = '';

      if (docs.isNotEmpty && docs.first.metadata != null) {
        final metadata = docs.first.metadata!;

        // Extract customer name
        final nameEntry = metadata.firstWhere(
          (m) => m.key == 'Customer Name',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );
        if (nameEntry.value.isNotEmpty) {
          customerName = nameEntry.value;
        }

        // Extract contact info (phone and email)
        final phoneEntry = metadata.firstWhere(
          (m) => m.key == 'Customer Phone',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );
        final emailEntry = metadata.firstWhere(
          (m) => m.key == 'Customer Email',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );

        final contactParts = <String>[];
        if (phoneEntry.value.isNotEmpty) contactParts.add(phoneEntry.value);
        if (emailEntry.value.isNotEmpty) contactParts.add(emailEntry.value);
        customerContact = contactParts.join(' • ');
      }

      final invoices = docs
          .map((doc) => calculator.buildAccountLineItem(doc))
          .toList();

      customers.add(
        Customer(
          customer_name: customerName,
          customer_contact: customerContact,
          invoices: invoices,
        ),
      );
    }

    return report.copyWith(
      generated_at: DateTime.now(),
      customers: customers,
      total_receivable: calculator.calculateTotalReceivable(),
      total_overdue: calculator.calculateTotalOverdue(),
      overdue_invoice_count: calculator.calculateOverdueInvoiceCount(),
    );
  }
}
