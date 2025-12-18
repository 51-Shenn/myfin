import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/acc_payable_calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Generator class for creating Accounts Payable Report
class AccPayableGenerator {
  Future<AccountsPayable> generateFullReport(
    AccountsPayable report,
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final asOfDate = report.fiscal_period['endDate']!;

    final calculator = AccountsPayableCalculator(
      documents: docData,
      lineItems: docLineData,
      asOfDate: asOfDate,
    );

    // Group documents by member ID
    final groupedByMember = calculator.groupByMemberId();
    final suppliers = <Supplier>[];

    // Build supplier list
    for (var entry in groupedByMember.entries) {
      final memberId = entry.key;
      final docs = entry.value;

      // TODO: Fetch member details from repository/database using memberId
      // For now, use memberId as the supplier name
      final supplierName =
          'Supplier $memberId'; // Replace with actual member name
      final supplierContact = ''; // Replace with actual contact info

      final bills = docs
          .map((doc) => calculator.buildAccountLineItem(doc))
          .toList();

      suppliers.add(
        Supplier(
          supplier_name: supplierName,
          supplier_contact: supplierContact,
          bills: bills,
        ),
      );
    }

    return report.copyWith(
      generated_at: DateTime.now(),
      suppliers: suppliers,
      total_payable: calculator.calculateTotalPayable(),
      total_overdue: calculator.calculateTotalOverdue(),
      overdue_bill_count: calculator.calculateOverdueBillCount(),
    );
  }
}
