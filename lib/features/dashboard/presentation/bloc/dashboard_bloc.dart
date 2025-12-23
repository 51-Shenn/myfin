import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';
import 'package:myfin/features/dashboard/domain/usecases/generate_cash_flow_snapshots.dart';
import 'package:myfin/features/dashboard/domain/usecases/get_cash_flow_dashboard_data.dart';
import 'package:myfin/features/dashboard/domain/usecases/subscribe_to_dashboard.dart';
import 'package:myfin/features/dashboard/data/datasources/dashboard_local_data_source.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetCashFlowDashboardData getDashboardData;
  final GenerateCashFlowSnapshots generateSnapshots;
  final SubscribeToDashboard subscribeToDashboard;
  final DashboardLocalDataSource localDataSource;

  DashboardBloc({
    required this.getDashboardData,
    required this.generateSnapshots,
    required this.subscribeToDashboard,
    required this.localDataSource,
  }) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardSubscriptionRequested>(_onSubscriptionRequested);
    on<DashboardFiscalPeriodChanged>(_onPeriodChanged);
    on<DashboardMoneyTypeChanged>(_onMoneyTypeChanged);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Generate snapshots first (fire and forget or wait, depending on need)
    // We wait to ensure data exists before subscribing
    try {
      await generateSnapshots(event.memberId);
      add(DashboardSubscriptionRequested(event.memberId));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onSubscriptionRequested(
    DashboardSubscriptionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await for (final snapshots in subscribeToDashboard(event.memberId)) {
      if (emit.isDone) break;

      // Filter out snapshots with no activity
      final activeSnapshots = snapshots
          .where((s) => s.totalIncome > 0 || s.totalExpense > 0)
          .toList();

      if (activeSnapshots.isEmpty) {
        emit(
          DashboardLoaded(
            snapshots: const [],
            currentSnapshot: _createEmptySnapshot(event.memberId),
            selectedPeriod: 'No Data',
            totalBalance: 0,
            incomeChangePercent: 0,
            refreshedAt: DateTime.now(),
          ),
        );
        continue;
      }

      // Sort snapshots descending by fiscal period (latest first)
      final sortedSnapshots = List<CashFlowSnapshot>.from(activeSnapshots)
        ..sort((a, b) => b.fiscalPeriod.compareTo(a.fiscalPeriod));

      // Preserve selected period if possible
      String selectedPeriod = sortedSnapshots.first.fiscalPeriod;
      if (state is DashboardLoaded) {
        final currentLoaded = state as DashboardLoaded;
        if (sortedSnapshots.any(
          (s) => s.fiscalPeriod == currentLoaded.selectedPeriod,
        )) {
          selectedPeriod = currentLoaded.selectedPeriod;
        }
      }

      final currentSnapshot = sortedSnapshots.firstWhere(
        (s) => s.fiscalPeriod == selectedPeriod,
        orElse: () => sortedSnapshots.first,
      );
      final incomeChange = _calculateIncomeTrend(
        currentSnapshot,
        sortedSnapshots,
      );

      final updatedState = await _fetchCategoriesAndLoad(
        sortedSnapshots,
        currentSnapshot,
        selectedPeriod,
        currentSnapshot.assets - currentSnapshot.liabilities,
        double.parse(incomeChange.toStringAsFixed(1)),
      );

      emit(updatedState);
    }
  }

  CashFlowSnapshot _createEmptySnapshot(String memberId) {
    return CashFlowSnapshot(
      snapshotId: 'empty',
      memberId: memberId,
      fiscalPeriod: 'No Data',
      assets: 0,
      liabilities: 0,
      totalIncome: 0,
      totalExpense: 0,
      netCashFlow: 0,
      createdAt: DateTime.now(),
    );
  }

  Future<DashboardLoaded> _fetchCategoriesAndLoad(
    List<CashFlowSnapshot> snapshots,
    CashFlowSnapshot currentSnapshot,
    String selectedPeriod,
    double totalBalance,
    double incomeChangePercent,
  ) async {
    final categories = await localDataSource.getMainCategories(
      currentSnapshot.snapshotId,
    );
    return DashboardLoaded(
      snapshots: snapshots,
      currentSnapshot: currentSnapshot,
      selectedPeriod: selectedPeriod,
      totalBalance: totalBalance,
      incomeChangePercent: incomeChangePercent,
      currentIncomeCategories: categories['income'] ?? {},
      currentExpenseCategories: categories['expense'] ?? {},
      refreshedAt: DateTime.now(),
    );
  }

  Future<void> _onPeriodChanged(
    DashboardFiscalPeriodChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      // Find snapshot for selected period
      final selectedSnapshot = currentState.snapshots.firstWhere(
        (s) => s.fiscalPeriod == event.period,
        orElse: () => currentState.currentSnapshot,
      );

      final incomeChange = _calculateIncomeTrend(
        selectedSnapshot,
        currentState.snapshots,
      );

      final updatedState = await _fetchCategoriesAndLoad(
        currentState.snapshots,
        selectedSnapshot,
        event.period,
        selectedSnapshot.assets - selectedSnapshot.liabilities,
        double.parse(incomeChange.toStringAsFixed(1)),
      );

      emit(updatedState.copyWith(showMoneyIn: currentState.showMoneyIn));
    }
  }

  void _onMoneyTypeChanged(
    DashboardMoneyTypeChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(showMoneyIn: event.showMoneyIn));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      print(
        '🔄 [DASHBOARD REFRESH] Starting refresh for member: ${event.memberId}',
      );

      // Regenerate snapshots to reflect any document changes
      await generateSnapshots(event.memberId);
      print('✅ [DASHBOARD REFRESH] Snapshots regenerated successfully');

      // Explicitly fetch the updated snapshots
      final updatedSnapshots = await getDashboardData(event.memberId);
      print(
        '📊 [DASHBOARD REFRESH] Fetched ${updatedSnapshots.length} snapshots',
      );

      // Filter out snapshots with no activity
      final activeSnapshots = updatedSnapshots
          .where((s) => s.totalIncome > 0 || s.totalExpense > 0)
          .toList();

      if (activeSnapshots.isEmpty) {
        print('⚠️ [DASHBOARD REFRESH] No active snapshots found');
        emit(
          DashboardLoaded(
            snapshots: const [],
            currentSnapshot: _createEmptySnapshot(event.memberId),
            selectedPeriod: 'No Data',
            totalBalance: 0,
            incomeChangePercent: 0,
            refreshedAt: DateTime.now(),
          ),
        );
        return;
      }

      // Sort snapshots descending by fiscal period (latest first)
      final sortedSnapshots = List<CashFlowSnapshot>.from(activeSnapshots)
        ..sort((a, b) => b.fiscalPeriod.compareTo(a.fiscalPeriod));

      // Preserve selected period if possible
      String selectedPeriod = sortedSnapshots.first.fiscalPeriod;
      if (state is DashboardLoaded) {
        final currentLoaded = state as DashboardLoaded;
        if (sortedSnapshots.any(
          (s) => s.fiscalPeriod == currentLoaded.selectedPeriod,
        )) {
          selectedPeriod = currentLoaded.selectedPeriod;
        }
      }

      final currentSnapshot = sortedSnapshots.firstWhere(
        (s) => s.fiscalPeriod == selectedPeriod,
        orElse: () => sortedSnapshots.first,
      );

      final incomeChange = _calculateIncomeTrend(
        currentSnapshot,
        sortedSnapshots,
      );

      final updatedState = await _fetchCategoriesAndLoad(
        sortedSnapshots,
        currentSnapshot,
        selectedPeriod,
        currentSnapshot.assets - currentSnapshot.liabilities,
        double.parse(incomeChange.toStringAsFixed(1)),
      );

      // Preserve the money type filter
      final showMoneyIn = state is DashboardLoaded
          ? (state as DashboardLoaded).showMoneyIn
          : true;

      emit(updatedState.copyWith(showMoneyIn: showMoneyIn));
      print('✅ [DASHBOARD REFRESH] Dashboard state updated successfully');
    } catch (e) {
      print('⚠️ [DASHBOARD REFRESH] Error during refresh: $e');
      // Don't emit error state as subscription is still active
    }
  }

  double _calculateIncomeTrend(
    CashFlowSnapshot current,
    List<CashFlowSnapshot> allSnapshots,
  ) {
    // Find the previous period (next one in the descending list that is older)
    // We assume strict month chronology isn't required, just "next available older record"
    // For stricter "previous month" check, we'd parser fiscalPeriod.
    try {
      // Filter for snapshots older than current
      final olderSnapshots = allSnapshots
          .where((s) => s.fiscalPeriod.compareTo(current.fiscalPeriod) < 0)
          .toList();

      if (olderSnapshots.isEmpty) return 0.0; // No previous data = 0% change

      // Get the immediate previous available snapshot
      final previous =
          olderSnapshots.first; // Since allSnapshots is sorted desc

      if (previous.totalIncome == 0) {
        return current.totalIncome > 0 ? 100.0 : 0.0;
      }

      return ((current.totalIncome - previous.totalIncome) /
              previous.totalIncome) *
          100;
    } catch (_) {
      return 0.0;
    }
  }
}
