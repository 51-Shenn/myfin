import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/data/models/tax_rate_model.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';

class TaxRegulationModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final List<TaxRateModel> rates;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedBy;
  final DateTime? deletedAt;

  TaxRegulationModel({
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

  factory TaxRegulationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle 'rates' which might be a List, or incorrectly a Map in Firestore
    var ratesData = data['rates'];
    List<TaxRateModel> parsedRates = [];

    try {
      if (ratesData is List) {
        // Safe iteration: check if element is a Map before casting
        for (var element in ratesData) {
          if (element is Map) {
            parsedRates.add(
                TaxRateModel.fromMap(Map<String, dynamic>.from(element)));
          }
        }
      } else if (ratesData is Map) {
        // Fallback: If rates were saved as a Map (e.g. index-keyed)
        for (var element in ratesData.values) {
          if (element is Map) {
            parsedRates.add(
                TaxRateModel.fromMap(Map<String, dynamic>.from(element)));
          }
        }
      }
    } catch (e) {
      print("Error parsing rates for regulation ${doc.id}: $e");
    }

    return TaxRegulationModel(
      id: doc.id,
      name: data['name'] as String,
      type: data['type'] as String,
      description: data['description'] as String,
      rates: () {
        final ratesData = data['rates'];
        if (ratesData == null) {
          return <TaxRateModel>[];
        } else if (ratesData is List) {
          // rates is stored as an array
          return ratesData
              .map(
                (rateMap) =>
                    TaxRateModel.fromMap(rateMap as Map<String, dynamic>),
              )
              .toList();
        } else if (ratesData is Map) {
          // rates is stored as a single object - convert to list
          return [TaxRateModel.fromMap(ratesData as Map<String, dynamic>)];
        } else {
          return <TaxRateModel>[];
        }
      }(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      deletedBy: data['deletedBy'] as String?,
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'rates': rates.map((rate) => rate.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedBy': deletedBy,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  TaxRegulation toEntity() {
    return TaxRegulation(
      id: id,
      name: name,
      type: type,
      description: description,
      rates: rates.map((rate) => rate.toEntity()).toList(),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedBy: deletedBy,
      deletedAt: deletedAt,
    );
  }

  factory TaxRegulationModel.fromEntity(TaxRegulation regulation) {
    return TaxRegulationModel(
      id: regulation.id,
      name: regulation.name,
      type: regulation.type,
      description: regulation.description,
      rates: regulation.rates
          .map((rate) => TaxRateModel.fromEntity(rate))
          .toList(),
      createdBy: regulation.createdBy,
      createdAt: regulation.createdAt,
      updatedAt: regulation.updatedAt,
      deletedBy: regulation.deletedBy,
      deletedAt: regulation.deletedAt,
    );
  }
}