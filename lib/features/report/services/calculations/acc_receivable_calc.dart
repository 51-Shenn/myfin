import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

class AccountsReceivableCalculator {
  final List<Document> documents;
  final List<DocumentLineItem> lineItems;
  final DateTime asOfDate;

  AccountsReceivableCalculator({
    required this.documents,
    required this.lineItems,
    required this.asOfDate,
  });

  List<Document> getReceivableDocuments() {
    return documents.where((doc) {
      return doc.type == 'Sales Invoice' &&
          (doc.status == 'Posted' || doc.status == 'Draft') &&
          doc.postingDate.isBefore(asOfDate.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, List<Document>> groupByMemberId() {
    final receivables = getReceivableDocuments();
    final Map<String, List<Document>> grouped = {};

    for (var doc in receivables) {
      final memberId = doc.memberId;
      if (!grouped.containsKey(memberId)) {
        grouped[memberId] = [];
      }
      grouped[memberId]!.add(doc);
    }

    return grouped;
  }

  double getDocumentTotal(String documentId) {
    final docLineItems = lineItems.where(
      (item) => item.documentId == documentId,
    );
    return docLineItems.fold(0.0, (sum, item) => sum + item.total);
  }

  DateTime _getDueDate(Document doc) {
    if (doc.metadata != null) {
      try {
        final dueDateMetadata = doc.metadata!.firstWhere(
          (m) => m.key == 'due_date',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );

        if (dueDateMetadata.value.isNotEmpty) {
          return DateTime.parse(dueDateMetadata.value);
        }
      } catch (e) {
        print('Error parsing due_date for document ${doc.id}: $e');
      }
    }

    return doc.postingDate.add(const Duration(days: 30));
  }

  bool isOverdue(Document doc) {
    final dueDate = _getDueDate(doc);
    return dueDate.isBefore(DateTime.now());
  }

  AccountLineItem buildAccountLineItem(Document doc) {
    return AccountLineItem(
      account_line_id: doc.id,
      date_issued: doc.postingDate,
      due_date: _getDueDate(doc),
      amount_due: getDocumentTotal(doc.id),
      isReceivable: true,
      isOverdue: isOverdue(doc),
    );
  }

  double calculateTotalReceivable() {
    return getReceivableDocuments().fold(
      0.0,
      (sum, doc) => sum + getDocumentTotal(doc.id),
    );
  }

  double calculateTotalOverdue() {
    return getReceivableDocuments()
        .where((doc) => isOverdue(doc))
        .fold(0.0, (sum, doc) => sum + getDocumentTotal(doc.id));
  }

  /// Calculate overdue invoice count
  int calculateOverdueInvoiceCount() {
    return getReceivableDocuments().where((doc) => isOverdue(doc)).length;
  }
}
