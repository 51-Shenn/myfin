import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Calculator class for Accounts Payable
/// Note: Member/supplier details should be fetched by the generator using repository calls
class AccountsPayableCalculator {
  final List<Document> documents;
  final List<DocumentLineItem> lineItems;
  final DateTime asOfDate;

  AccountsPayableCalculator({
    required this.documents,
    required this.lineItems,
    required this.asOfDate,
  });

  /// Get all payable documents (bills)
  List<Document> getPayableDocuments() {
    return documents.where((doc) {
      return doc.type == 'Bill' &&
          doc.postingDate.isBefore(asOfDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Group documents by member ID (supplier ID)
  /// Returns map of memberId -> list of documents
  Map<String, List<Document>> groupByMemberId() {
    final payables = getPayableDocuments();
    final Map<String, List<Document>> grouped = {};

    for (var doc in payables) {
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
      isReceivable: false,
      isOverdue: isOverdue(doc),
    );
  }

  /// Calculate total payable across all suppliers
  double calculateTotalPayable() {
    return getPayableDocuments().fold(
      0.0,
      (sum, doc) => sum + getDocumentTotal(doc.id),
    );
  }

  /// Calculate total overdue amounts
  double calculateTotalOverdue() {
    return getPayableDocuments()
        .where((doc) => isOverdue(doc))
        .fold(0.0, (sum, doc) => sum + getDocumentTotal(doc.id));
  }

  /// Calculate overdue bill count
  int calculateOverdueBillCount() {
    return getPayableDocuments().where((doc) => isOverdue(doc)).length;
  }
}
