import 'package:hive/hive.dart';
import 'package:myfin/features/dashboard/data/models/cash_flow_snapshot_model.dart';

abstract class DashboardLocalDataSource {
  Future<List<CashFlowSnapshotModel>> getCachedSnapshots(String memberId);
  Future<void> cacheSnapshots(
    String memberId,
    List<CashFlowSnapshotModel> snapshots,
  );
  Future<void> clearCache(String memberId);

  // Main category cache
  Future<Map<String, Map<String, double>>> getMainCategories(String snapshotId);
  Future<void> cacheMainCategories(
    String snapshotId,
    Map<String, double> income,
    Map<String, double> expense,
  );
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Box<dynamic> box;

  DashboardLocalDataSourceImpl({required this.box});

  String _getCacheKey(String memberId) => 'snapshots_$memberId';

  @override
  Future<List<CashFlowSnapshotModel>> getCachedSnapshots(
    String memberId,
  ) async {
    try {
      final data = box.get(_getCacheKey(memberId));
      if (data == null) {
        return [];
      }

      // Deserialize from cache-safe JSON
      return (data as List)
          .map(
            (e) => CashFlowSnapshotModel.fromCacheJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e) {
      // If cache is corrupted, return empty and clear it
      await clearCache(memberId);
      return [];
    }
  }

  @override
  Future<void> cacheSnapshots(
    String memberId,
    List<CashFlowSnapshotModel> snapshots,
  ) async {
    try {
      // Serialize to cache-safe JSON (no Timestamp objects)
      final jsonList = snapshots.map((s) => s.toCacheJson()).toList();
      await box.put(_getCacheKey(memberId), jsonList);
    } catch (e) {
      // Silently fail - caching is not critical
    }
  }

  // Main category cache methods
  Future<Map<String, Map<String, double>>> getMainCategories(
    String snapshotId,
  ) async {
    try {
      final key = 'main_categories_$snapshotId';
      final data = box.get(key);
      if (data == null) {
        return {'income': {}, 'expense': {}};
      }

      return {
        'income': Map<String, double>.from(data['income'] ?? {}),
        'expense': Map<String, double>.from(data['expense'] ?? {}),
      };
    } catch (e) {
      return {'income': {}, 'expense': {}};
    }
  }

  Future<void> cacheMainCategories(
    String snapshotId,
    Map<String, double> income,
    Map<String, double> expense,
  ) async {
    try {
      final key = 'main_categories_$snapshotId';
      await box.put(key, {'income': income, 'expense': expense});
    } catch (e) {
      // Silently fail - caching is not critical
    }
  }

  @override
  Future<void> clearCache(String memberId) async {
    try {
      await box.delete(_getCacheKey(memberId));
    } catch (e) {
      // Silently fail
    }
  }
}
