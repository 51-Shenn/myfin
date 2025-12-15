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
  final List<AdditionalInfoRow> attribute; 

  DocumentLineItem({
    required this.lineItemId,
    required this.documentId,
    required this.lineNo,
    this.lineDate,
    required this.categoryCode,
    this.description,
    required this.debit,
    required this.credit,
    required this.attribute,
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
      'attribute': attribute.map((x) => x.toMap()).toList(),
    };
  }

  factory DocumentLineItem.fromMap(Map<String, dynamic> data) {
    DateTime? convert(dynamic v) =>
        v == null ? null : (v is Timestamp ? v.toDate() : v as DateTime);

    return DocumentLineItem(
      lineItemId: data['lineItemId'] as String? ?? '',
      documentId: data['documentId'] as String? ?? '',
      lineNo: data['lineNo'] as int? ?? 0,
      lineDate: convert(data['lineDate']),
      categoryCode: data['categoryCode'] as String? ?? '',
      description: data['description'] as String?,
      debit: (data['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (data['credit'] as num?)?.toDouble() ?? 0.0,
      attribute: (data['attribute'] as List<dynamic>?)
              ?.map((x) => AdditionalInfoRow.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory DocumentLineItem.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    DateTime? convert(dynamic v) =>
        v == null ? null : (v is Timestamp ? v.toDate() : v as DateTime);

    return DocumentLineItem(
      lineItemId: snap.id,
      documentId: data['documentId'] as String? ?? '',
      lineNo: data['lineNo'] as int? ?? 0,
      lineDate: convert(data['lineDate']),
      categoryCode: data['categoryCode'] as String? ?? '',
      description: data['description'] as String?,
      debit: (data['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (data['credit'] as num?)?.toDouble() ?? 0.0,
      attribute: (data['attribute'] as List<dynamic>?)
              ?.map((x) => AdditionalInfoRow.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DocumentLineItem copyWith({
    String? lineItemId,
    String? documentId,
    int? lineNo,
    DateTime? lineDate,
    String? categoryCode,
    String? description,
    double? debit,
    double? credit,
    List<AdditionalInfoRow>? attribute,
  }) {
    return DocumentLineItem(
      lineItemId: lineItemId ?? this.lineItemId,
      documentId: documentId ?? this.documentId,
      lineNo: lineNo ?? this.lineNo,
      lineDate: lineDate ?? this.lineDate,
      categoryCode: categoryCode ?? this.categoryCode,
      description: description ?? this.description,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      attribute: attribute ?? this.attribute,
    );
  }
}

class AdditionalInfoRow {
  final String id;
  final String key;
  final String value;

  AdditionalInfoRow({
    required this.id,
    required this.key,
    required this.value,
  });

  AdditionalInfoRow copyWith({
    String? id,
    String? key,
    String? value,
  }) {
    return AdditionalInfoRow(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
    };
  }

  factory AdditionalInfoRow.fromMap(Map<String, dynamic> map) {
    return AdditionalInfoRow(
      id: map['id'] as String? ?? '',
      key: map['key'] as String? ?? '',
      value: map['value'] as String? ?? '',
    );
  }
}