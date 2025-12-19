import 'package:equatable/equatable.dart';

class CashFlowSnapshot extends Equatable {
  final String snapshotId;
  final DateTime createdAt;
  final String fiscalPeriod;
  final double totalIncome; // Sum of income main categories
  final double totalExpense; // Sum of expense main categories
  final double netCashFlow;
  final double assets;
  final double liabilities;
  final String memberId;

  const CashFlowSnapshot({
    required this.snapshotId,
    required this.createdAt,
    required this.fiscalPeriod,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.assets,
    required this.liabilities,
    required this.memberId,
  });

  @override
  List<Object?> get props => [
    snapshotId,
    createdAt,
    fiscalPeriod,
    totalIncome,
    totalExpense,
    netCashFlow,
    assets,
    liabilities,
    memberId,
  ];
}
