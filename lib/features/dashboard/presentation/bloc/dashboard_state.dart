part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<CashFlowSnapshot> snapshots;
  final CashFlowSnapshot currentSnapshot;
  final String selectedPeriod;
  final bool showMoneyIn;
  final double totalBalance;
  final double incomeChangePercent;

  final Map<String, double> currentIncomeCategories;
  final Map<String, double> currentExpenseCategories;

  // Add timestamp to ensure each refresh creates a new state instance
  final DateTime refreshedAt;

  DashboardLoaded({
    required this.snapshots,
    required this.currentSnapshot,
    required this.selectedPeriod,
    this.showMoneyIn = true,
    this.totalBalance = 0,
    this.incomeChangePercent = 0,
    this.currentIncomeCategories = const {},
    this.currentExpenseCategories = const {},
    required this.refreshedAt,
  });

  DashboardLoaded copyWith({
    List<CashFlowSnapshot>? snapshots,
    CashFlowSnapshot? currentSnapshot,
    String? selectedPeriod,
    bool? showMoneyIn,
    double? totalBalance,
    double? incomeChangePercent,
    Map<String, double>? currentIncomeCategories,
    Map<String, double>? currentExpenseCategories,
    DateTime? refreshedAt,
  }) {
    return DashboardLoaded(
      snapshots: snapshots ?? this.snapshots,
      currentSnapshot: currentSnapshot ?? this.currentSnapshot,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      showMoneyIn: showMoneyIn ?? this.showMoneyIn,
      totalBalance: totalBalance ?? this.totalBalance,
      incomeChangePercent: incomeChangePercent ?? this.incomeChangePercent,
      currentIncomeCategories:
          currentIncomeCategories ?? this.currentIncomeCategories,
      currentExpenseCategories:
          currentExpenseCategories ?? this.currentExpenseCategories,
      refreshedAt: refreshedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object> get props => [
    snapshots,
    currentSnapshot,
    selectedPeriod,
    showMoneyIn,
    totalBalance,
    incomeChangePercent,
    currentIncomeCategories,
    currentExpenseCategories,
    refreshedAt,
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
