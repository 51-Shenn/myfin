import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class Document {
  final String id; // PK
  final String memberId; // FK
  final String name;
  final String type;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime postingDate;
  final List<AdditionalInfoRow>? metadata; 
  final String? refDocType;
  final String? refDocId;

  Document({
    required this.id,
    required this.memberId,
    required this.name,
    required this.type,
    required this.status,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.postingDate,
    this.metadata,
    this.refDocType,
    this.refDocId,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'postingDate': postingDate,
      'metadata': metadata?.map((x) => x.toMap()).toList(),
      'refDocType': refDocType,
      'refDocId': refDocId,
      'memberId': memberId
    };
  }

  factory Document.fromMap(Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Document(
      id: data['id'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? '',
      status: data['status'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: toDateTime(data['createdAt']),
      updatedAt: toDateTime(data['updatedAt']),
      postingDate: toDateTime(data['postingDate']),
      metadata: (data['metadata'] as List<dynamic>?)
          ?.map((x) => AdditionalInfoRow.fromMap(x as Map<String, dynamic>))
          .toList(),
      refDocType: data['refDocType'] as String?,
      refDocId: data['refDocId'] as String?,
    );
  }

  factory Document.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Document(
      id: snap.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? '',
      status: data['status'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      createdAt: toDateTime(data['createdAt']),
      updatedAt: toDateTime(data['updatedAt']),
      postingDate: toDateTime(data['postingDate']),
      metadata: (data['metadata'] as List<dynamic>?)
          ?.map((x) => AdditionalInfoRow.fromMap(x as Map<String, dynamic>))
          .toList(),
      refDocType: data['refDocType'] as String?,
      refDocId: data['refDocId'] as String?,
    );
  }

  Document copyWith({
    String? id,
    String? memberId,
    String? name,
    String? type,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? postingDate,
    List<AdditionalInfoRow>? metadata,
    String? refDocType,
    String? refDocId,
  }) {
    return Document(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postingDate: postingDate ?? this.postingDate,
      metadata: metadata ?? this.metadata,
      refDocType: refDocType ?? this.refDocType,
      refDocId: refDocId ?? this.refDocId,
    );
  }
}