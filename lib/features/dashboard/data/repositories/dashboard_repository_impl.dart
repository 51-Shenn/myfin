import 'package:myfin/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:myfin/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:myfin/features/dashboard/data/models/cash_flow_snapshot_model.dart';
import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';
import 'package:myfin/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<CashFlowSnapshot>> getCashFlowSnapshots(String memberId) async {
    // 1. Try local cache first
    final cached = await localDataSource.getCachedSnapshots(memberId);
    if (cached.isNotEmpty) {
      return cached.cast<CashFlowSnapshot>();
    }

    // 2. Fetch from Firebase if cache is empty
    final remote = await remoteDataSource.getCashFlowSnapshots(memberId);

    // 3. Save to cache for next time
    await localDataSource.cacheSnapshots(memberId, remote);

    return remote.cast<CashFlowSnapshot>();
  }

  @override
  Future<CashFlowSnapshot> getLatestSnapshot(String memberId) async {
    final snapshots = await getCashFlowSnapshots(memberId);
    if (snapshots.isNotEmpty) {
      return snapshots.first;
    } else {
      throw Exception('No snapshot found');
    }
  }

  @override
  Future<void> saveCashFlowSnapshots(List<CashFlowSnapshot> snapshots) async {
    final snapshotModels = snapshots
        .map(
          (s) => CashFlowSnapshotModel(
            snapshotId: s.snapshotId,
            createdAt: s.createdAt,
            fiscalPeriod: s.fiscalPeriod,
            totalIncome: s.totalIncome,
            totalExpense: s.totalExpense,
            netCashFlow: s.netCashFlow,
            assets: s.assets,
            liabilities: s.liabilities,
            memberId: s.memberId,
          ),
        )
        .toList();
    await remoteDataSource.saveCashFlowSnapshots(snapshotModels);

    // Update cache after saving (Snapshots only, categories are cached during generation)
    await localDataSource.cacheSnapshots(
      snapshots.first.memberId,
      snapshotModels,
    );
  }

  @override
  Stream<List<CashFlowSnapshot>> getSnapshotsStream(String memberId) {
    return remoteDataSource.getSnapshotsStream(memberId).asyncMap((
      models,
    ) async {
      // Cache each stream emission for offline access
      await localDataSource.cacheSnapshots(memberId, models);
      return models.cast<CashFlowSnapshot>();
    });
  }
}
