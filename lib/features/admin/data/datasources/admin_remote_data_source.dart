import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/data/models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminUserModel>> fetchUsers();
  Future<void> banUser(String userId, String currentStatus);
  Future<void> deleteUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data); // Added
  Future<Map<String, int>> fetchStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AdminUserModel>> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('members').get();
      return snapshot.docs
          .map((doc) => AdminUserModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch users: $e");
    }
  }

  @override
  Future<void> banUser(String userId, String currentStatus) async {
    try {
      // Toggle logic: if Active -> Banned, else -> Active
      // Firestore usually stores status in lowercase
      final newStatus = (currentStatus.toLowerCase() == 'active') ? 'banned' : 'active';
      
      await _firestore.collection('members').doc(userId).update({
        'status': newStatus
      });
    } catch (e) {
      throw Exception("Failed to ban user: $e");
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // Hard delete from members collection
      await _firestore.collection('members').doc(userId).delete();
      
      // Optional: Delete related data (business profiles, etc.) here if needed
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('members').doc(userId).update(data);
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }

  @override
  Future<Map<String, int>> fetchStats() async {
    try {
      final snapshot = await _firestore.collection('members').get();
      final docs = snapshot.docs;

      int total = docs.length;
      int banned = 0;
      int newToday = 0;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      for (var doc in docs) {
        final data = doc.data();
        
        // Count Banned
        if (data['status'] == 'banned') {
          banned++;
        }

        // Count New Today
        if (data['created_at'] != null) {
          final Timestamp createdAt = data['created_at'];
          if (createdAt.toDate().isAfter(startOfDay)) {
            newToday++;
          }
        }
      }

      return {
        "total": total,
        "new": newToday,
        "banned": banned,
      };
    } catch (e) {
      return {
        "total": 0,
        "new": 0,
        "banned": 0,
      };
    }
  }
}