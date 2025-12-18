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
      final memberId = entry.key;
      final docs = entry.value;

      // TODO: Fetch member details from repository/database using memberId
      // For now, use memberId as the customer name
      final customerName =
          'Customer $memberId'; // Replace with actual member name
      final customerContact = ''; // Replace with actual contact info

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
