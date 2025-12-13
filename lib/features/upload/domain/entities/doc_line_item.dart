

import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentLineItem {
  final String lineItemId; // PK
  final String documentId; // FK
  final int lineNo;
  final DateTime? lineDate;
  final String categoryCode;
  final String? description;
  final double debit;
  final double credit;
  final List<Object> attribute;

  DocumentLineItem({
    required this.lineItemId,
    required this.documentId,
    required this.lineNo,
    this.lineDate,
    required this.categoryCode,
    this.description,
    required this.debit,
    required this.credit,
    required this.attribute
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'lineNo': lineNo,
      'lineDate': lineDate,
      'categoryCode': categoryCode,
      'description': description,
      'debit': debit,
      'credit': credit,
      'attribute': attribute,
    };
  }

  factory DocumentLineItem.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    DateTime? convert(dynamic v) =>
        v == null ? null : (v is Timestamp ? v.toDate() : v as DateTime);

    return DocumentLineItem(
      lineItemId: snap.id,
      documentId: data['documentId'],
      lineNo: data['lineNo'],
      lineDate: convert(data['lineDate']),
      categoryCode: data['categoryCode'],
      description: data['description'],
      debit: (data['debit'] as num).toDouble(),
      credit: (data['credit'] as num).toDouble(),
      attribute: data['attribute'],
    );
  }
}