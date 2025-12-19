import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';

class CashFlowSnapshotModel extends CashFlowSnapshot {
  const CashFlowSnapshotModel({
    required super.snapshotId,
    required super.createdAt,
    required super.fiscalPeriod,
    required super.totalIncome,
    required super.totalExpense,
    required super.netCashFlow,
    required super.assets,
    required super.liabilities,
    required super.memberId,
  });

  factory CashFlowSnapshotModel.fromJson(Map<String, dynamic> json) {
    return CashFlowSnapshotModel(
      snapshotId: json['snapshot_id'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      fiscalPeriod: json['fiscal_period'] as String,
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),
      assets: (json['assets'] as num).toDouble(),
      liabilities: (json['liabilities'] as num).toDouble(),
      memberId: json['member_id'] as String,
      // Categories will be computed from transactions, not loaded from Firebase
    );
  }

  Map<String, dynamic> toJson() {
    // Categories are computed from transactions, no need to store in Firebase
    return {
      'snapshot_id': snapshotId,
      'created_at': Timestamp.fromDate(createdAt),
      'fiscal_period': fiscalPeriod,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_cash_flow': netCashFlow,
      'assets': assets,
      'liabilities': liabilities,
      'member_id': memberId,
      // 'categories': excluded to save storage (computed from transactions)
    };
  }

  // Cache-safe JSON without Firestore Timestamp
  Map<String, dynamic> toCacheJson() {
    return {
      'snapshot_id': snapshotId,
      'created_at': createdAt.toIso8601String(), // Convert to string for Hive
      'fiscal_period': fiscalPeriod,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_cash_flow': netCashFlow,
      'assets': assets,
      'liabilities': liabilities,
      'member_id': memberId,
      // Main categories cached separately
    };
  }

  // Deserialize from cache
  factory CashFlowSnapshotModel.fromCacheJson(Map<String, dynamic> json) {
    return CashFlowSnapshotModel(
      snapshotId: json['snapshot_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fiscalPeriod: json['fiscal_period'] as String,
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),
      assets: (json['assets'] as num).toDouble(),
      liabilities: (json['liabilities'] as num).toDouble(),
      memberId: json['member_id'] as String,
      // Main categories loaded separately from cache
    );
  }
}
