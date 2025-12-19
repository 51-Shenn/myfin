import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';

abstract class DashboardRepository {
  Future<List<CashFlowSnapshot>> getCashFlowSnapshots(String memberId);
  Stream<List<CashFlowSnapshot>> getSnapshotsStream(String memberId);
  Future<CashFlowSnapshot> getLatestSnapshot(String memberId);
  Future<void> saveCashFlowSnapshots(List<CashFlowSnapshot> snapshots);
}
