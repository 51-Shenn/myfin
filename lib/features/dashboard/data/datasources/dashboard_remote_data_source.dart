import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/dashboard/data/models/cash_flow_snapshot_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<CashFlowSnapshotModel>> getCashFlowSnapshots(String memberId);
  Stream<List<CashFlowSnapshotModel>> getSnapshotsStream(String memberId);
  Future<void> saveCashFlowSnapshots(List<CashFlowSnapshotModel> snapshots);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  DashboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CashFlowSnapshotModel>> getCashFlowSnapshots(
    String memberId,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection('cash_flow_snapshot')
          .where('member_id', isEqualTo: memberId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CashFlowSnapshotModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  @override
  Future<void> saveCashFlowSnapshots(
    List<CashFlowSnapshotModel> snapshots,
  ) async {
    final batch = firestore.batch();
    for (var snapshot in snapshots) {
      final docRef = firestore
          .collection('cash_flow_snapshot')
          .doc(snapshot.snapshotId);
      batch.set(docRef, snapshot.toJson());
    }
    await batch.commit();
  }

  @override
  Stream<List<CashFlowSnapshotModel>> getSnapshotsStream(String memberId) {
    return firestore
        .collection('cash_flow_snapshot')
        .where('member_id', isEqualTo: memberId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CashFlowSnapshotModel.fromJson(doc.data()))
              .toList();
        });
  }
}
