import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentImage {
  final String id; // Same as document ID
  final String imageBase64;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentImage({
    required this.id,
    required this.imageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'imageBase64': imageBase64,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory DocumentImage.fromMap(String id, Map<String, dynamic> data) {
    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return DocumentImage(
      id: id,
      imageBase64: data['imageBase64'] as String? ?? '',
      createdAt: toDateTime(data['createdAt']),
      updatedAt: toDateTime(data['updatedAt']),
    );
  }

  factory DocumentImage.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return DocumentImage.fromMap(snap.id, data);
  }

  DocumentImage copyWith({
    String? id,
    String? imageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentImage(
      id: id ?? this.id,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
