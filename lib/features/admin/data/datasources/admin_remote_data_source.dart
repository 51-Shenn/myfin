import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
import 'package:myfin/features/admin/data/models/admin_user_model.dart';
import 'package:myfin/core/utils/image_chunker_service.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminUserModel>> fetchUsers();
  Future<void> banUser(String userId, String currentStatus);
  Future<void> deleteUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Future<Map<String, int>> fetchStats();
  Future<Admin> fetchCurrentAdmin(String adminId); 
  Future<void> updateAdminProfile(String adminId, Map<String, dynamic> data);
  Future<void> uploadAdminImage(String adminId, File imageFile);
  Future<String?> fetchAdminImageBase64(String adminId);
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

  @override
  Future<Admin> fetchCurrentAdmin(String adminId) async {
    try {
      final doc = await _firestore.collection('admins').doc(adminId).get();

      if (!doc.exists) {
        throw Exception("Admin profile not found in database.");
      }

      final data = doc.data() as Map<String, dynamic>;

      return Admin(
        adminId: doc.id,
        username: data['username'] ?? 'Admin',
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        email: data['email'] ?? '',
        createdAt: data['created_at'] != null 
            ? (data['created_at'] as Timestamp).toDate() 
            : DateTime.now(),
      );
    } catch (e) {
      throw Exception("Failed to fetch admin profile: $e");
    }
  }

  @override
  Future<void> updateAdminProfile(String adminId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('admins').doc(adminId).update(data);
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  @override
  Future<void> uploadAdminImage(String adminId, File imageFile) async {
    try {
      // 1. Convert to Base64
      final base64String = await ImageChunkerService.fileToBase64(imageFile);
      // 2. Split
      final chunks = ImageChunkerService.splitString(base64String);

      // 3. Define collection: admins/{id}/profile_image_chunks
      final collectionRef = _firestore
          .collection('admins')
          .doc(adminId)
          .collection('profile_image_chunks');

      // 4. Delete old chunks
      final existingDocs = await collectionRef.get();
      final batchDelete = _firestore.batch();
      for (var doc in existingDocs.docs) {
        batchDelete.delete(doc.reference);
      }
      await batchDelete.commit();

      // 5. Upload new chunks
      final batchWrite = _firestore.batch();
      for (int i = 0; i < chunks.length; i++) {
        final docRef = collectionRef.doc(i.toString());
        batchWrite.set(docRef, {
          'index': i,
          'data': chunks[i],
          'total_chunks': chunks.length,
        });
      }
      
      await batchWrite.commit();
    } catch (e) {
      throw Exception("Failed to upload admin image: $e");
    }
  }

  @override
  Future<String?> fetchAdminImageBase64(String adminId) async {
    try {
      final collectionRef = _firestore
          .collection('admins')
          .doc(adminId)
          .collection('profile_image_chunks');

      final querySnapshot = await collectionRef.orderBy('index').get();

      if (querySnapshot.docs.isEmpty) return null;

      final StringBuffer buffer = StringBuffer();
      for (var doc in querySnapshot.docs) {
        buffer.write(doc['data'] as String);
      }

      return buffer.toString();
    } catch (e) {
      throw Exception("Failed to fetch admin image: $e");
    }
  }
}