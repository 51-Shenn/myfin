
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<Object>? metadata;
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
    required this.updatedAt,
    required this.postingDate,
    this.metadata,
    this.refDocType,
    this.refDocId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'status': status,
      'createdBy': createdBy,
      
      'createdAt': createdAt, 
      'updatedAt': updatedAt, 
      'postingDate': postingDate,
      
      'metadata': metadata,
      'refDocType': refDocType,
      'refDocId': refDocId,
      'memberId': memberId
    };
  }

  factory Document.fromMap(Map<String, dynamic> data) {
    // helper method
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return (value is DateTime) ? value : DateTime.now();
    }
    
    return Document(
      id: data['id'] as String, 
      name: data['name'] as String,
      type: data['type'] as String,
      status: data['status'] as String,
      createdBy: data['createdBy'] as String,
      
      createdAt: toDateTime(data['createdAt']),
      updatedAt: toDateTime(data['updatedAt']),
      postingDate: toDateTime(data['postingDate']),

      metadata: data['metadata'] as List<Object>?,
      refDocType: data['refDocType'] as String?,
      refDocId: data['refDocId'] as String?,
      memberId: data['memberId'] as String,
    );
  }

  // factory Document.fromSnapshot(DocumentSnapshot snap) {
  //   final data = snap.data() as Map<String, dynamic>;

  //   DateTime toDateTime(dynamic value) {
  //     if (value is Timestamp) return value.toDate();
  //     if (value is DateTime) return value;
  //     return DateTime.now();
  //   }

  //   return Document(
  //     id: snap.id, // <-- must come from snapshot
  //     name: data['name'],
  //     type: data['type'],
  //     status: data['status'],
  //     createdBy: data['createdBy'],
  //     memberId: data['memberId'],
  //     createdAt: toDateTime(data['createdAt']),
  //     updatedAt: toDateTime(data['updatedAt']),
  //     postingDate: toDateTime(data['postingDate']),
  //     metadata: data['metadata'],
  //     refDocType: data['refDocType'],
  //     refDocId: data['refDocId'],
  //   );
  // }
}