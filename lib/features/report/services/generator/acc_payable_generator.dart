import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/acc_payable_calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

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

    final groupedByMember = calculator.groupByMemberId();
    final suppliers = <Supplier>[];

    for (var entry in groupedByMember.entries) {
      final docs = entry.value;

      String supplierName = '';
      String supplierContact = '';

      if (docs.isNotEmpty && docs.first.metadata != null) {
        final metadata = docs.first.metadata!;

        final nameEntry = metadata.firstWhere(
          (m) => m.key == 'Supplier Name',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );
        if (nameEntry.value.isNotEmpty) {
          supplierName = nameEntry.value;
        }

        final phoneEntry = metadata.firstWhere(
          (m) => m.key == 'Supplier Phone',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );
        final emailEntry = metadata.firstWhere(
          (m) => m.key == 'Supplier Email',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );

        final contactParts = <String>[];
        if (phoneEntry.value.isNotEmpty) contactParts.add(phoneEntry.value);
        if (emailEntry.value.isNotEmpty) contactParts.add(emailEntry.value);
        supplierContact = contactParts.join(' • ');
      }

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
