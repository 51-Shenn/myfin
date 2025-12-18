import 'package:equatable/equatable.dart';
import 'package:myfin/features/admin/domain/entities/tax_rate.dart';

class TaxRegulation extends Equatable {
  final String id;
  final String name;
  final String type;
  final String description;
  final List<TaxRate> rates;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedBy;
  final DateTime? deletedAt;

  const TaxRegulation({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.rates,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedBy,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    description,
    rates,
    createdBy,
    createdAt,
    updatedAt,
    deletedBy,
    deletedAt,
  ];

  TaxRegulation copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    List<TaxRate>? rates,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedBy,
    DateTime? deletedAt,
  }) {
    return TaxRegulation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      rates: rates ?? this.rates,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
