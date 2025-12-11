class Document {
  final String id;
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
}