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

  /// Get all payable documents (bills and related documents)
  List<Document> getPayableDocuments() {
    return documents.where((doc) {
      return (doc.status == 'Posted' || doc.status == 'Approved') &&
          (doc.metadata?.map((m) => m.key).contains('Supplier Name') ??
              false) && // check if the metadata inside got Supplier keyword
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

  /// Get due date from document metadata
  /// Returns the due date from metadata if available, otherwise defaults to 30 days from posting date
  DateTime _getDueDate(Document doc) {
    // Try to get due_date from metadata
    if (doc.metadata != null) {
      try {
        final dueDateMetadata = doc.metadata!.firstWhere(
          (m) => m.key == 'due_date',
          orElse: () => AdditionalInfoRow(id: '', key: '', value: ''),
        );

        if (dueDateMetadata.value.isNotEmpty) {
          // Parse YYYY-MM-DD format
          return DateTime.parse(dueDateMetadata.value);
        }
      } catch (e) {
        // If parsing fails, fall back to default
        print('Error parsing due_date for document ${doc.id}: $e');
      }
    }

    // Fallback: 30 days from posting date
    return doc.postingDate.add(const Duration(days: 30));
  }

  /// Check if a document is overdue
  bool isOverdue(Document doc) {
    final dueDate = _getDueDate(doc);
    return dueDate.isBefore(DateTime.now());
  }

  /// Build AccountLineItem from a document
  AccountLineItem buildAccountLineItem(Document doc) {
    return AccountLineItem(
      account_line_id: doc.id,
      date_issued: doc.postingDate,
      due_date: _getDueDate(doc),
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
