import 'package:equatable/equatable.dart';

class TaxRate extends Equatable {
  final String id;
  final double minimumIncome;
  final double maximumIncome;
  final double percentage;

  const TaxRate({
    required this.id,
    required this.minimumIncome,
    required this.maximumIncome,
    required this.percentage,
  });

  @override
  List<Object?> get props => [id, minimumIncome, maximumIncome, percentage];

  TaxRate copyWith({
    String? id,
    double? minimumIncome,
    double? maximumIncome,
    double? percentage,
  }) {
    return TaxRate(
      id: id ?? this.id,
      minimumIncome: minimumIncome ?? this.minimumIncome,
      maximumIncome: maximumIncome ?? this.maximumIncome,
      percentage: percentage ?? this.percentage,
    );
  }
}
