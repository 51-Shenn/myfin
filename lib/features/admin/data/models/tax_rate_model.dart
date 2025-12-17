import 'package:myfin/features/admin/domain/entities/tax_rate.dart';

class TaxRateModel {
  final String id;
  final double minimumIncome;
  final double maximumIncome;
  final double percentage;

  TaxRateModel({
    required this.id,
    required this.minimumIncome,
    required this.maximumIncome,
    required this.percentage,
  });

  factory TaxRateModel.fromMap(Map<String, dynamic> map) {
    return TaxRateModel(
      id: map['id'] as String,
      minimumIncome: (map['minimumIncome'] as num).toDouble(),
      maximumIncome: (map['maximumIncome'] as num).toDouble(),
      percentage: (map['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'minimumIncome': minimumIncome,
      'maximumIncome': maximumIncome,
      'percentage': percentage,
    };
  }

  TaxRate toEntity() {
    return TaxRate(
      id: id,
      minimumIncome: minimumIncome,
      maximumIncome: maximumIncome,
      percentage: percentage,
    );
  }

  factory TaxRateModel.fromEntity(TaxRate rate) {
    return TaxRateModel(
      id: rate.id,
      minimumIncome: rate.minimumIncome,
      maximumIncome: rate.maximumIncome,
      percentage: rate.percentage,
    );
  }
}
