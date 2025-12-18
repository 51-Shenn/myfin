import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Calculator class for Accounts Receivable
/// Note: Member/customer details should be fetched by the generator using repository calls
class AccountsReceivableCalculator {
  final List<Document> documents;
  final List<DocumentLineItem> lineItems;
  final DateTime asOfDate;

  AccountsReceivableCalculator({
    required this.documents,
    required this.lineItems,
    required this.asOfDate,
  });

  /// Get all receivable documents (invoices)
  List<Document> getReceivableDocuments() {
    return documents.where((doc) {
      return doc.type == 'Invoice' &&
          doc.status == 'Posted' &&
          doc.postingDate.isBefore(asOfDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Group documents by member ID (customer ID)
  /// Returns map of memberId -> list of documents
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

  /// Get total amount for a document by summing its line items
  double getDocumentTotal(String documentId) {
    final docLineItems = lineItems.where(
      (item) => item.documentId == documentId,
    );
    return docLineItems.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Check if a document is overdue
  /// Note: Due date should be calculated or stored in metadata
  bool isOverdue(Document doc) {
    // TODO: Get actual due date from metadata or calculate based on payment terms
    // For now, assume 30 days from posting date
    final dueDate = doc.postingDate.add(const Duration(days: 30));
    return dueDate.isBefore(DateTime.now());
  }

  /// Build AccountLineItem from a document
  AccountLineItem buildAccountLineItem(Document doc) {
    return AccountLineItem(
      account_line_id: doc.id,
      date_issued: doc.postingDate,
      due_date: doc.postingDate.add(
        const Duration(days: 30),
      ), // TODO: Get from metadata
      amount_due: getDocumentTotal(doc.id),
      isReceivable: true,
      isOverdue: isOverdue(doc),
    );
  }

  /// Calculate total receivable across all customers
  double calculateTotalReceivable() {
    return getReceivableDocuments().fold(
      0.0,
      (sum, doc) => sum + getDocumentTotal(doc.id),
    );
  }

  /// Calculate total overdue amounts
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
