import 'dart:io';
import 'dart:convert'; 
import 'dart:typed_data'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:myfin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  Future<Admin> getAdminDetails() async {
    // 1. Get Current User ID
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      throw Exception("No user currently logged in.");
    }

    // 2. Fetch Details from Firestore using the ID
    return await remoteDataSource.fetchCurrentAdmin(user.uid);
  }

  Future<List<AdminUserView>> getUsers() async {
    return await remoteDataSource.fetchUsers();
  }

  Future<Map<String, int>> getStats() async {
    return await remoteDataSource.fetchStats();
  }

  Future<void> banUser(String userId, String currentStatus) async {
    await remoteDataSource.banUser(userId, currentStatus);
  }

  Future<void> deleteUser(String userId) async {
    await remoteDataSource.deleteUser(userId);
  }

  Future<void> updateUser(String userId, String firstName, String lastName, String email, String phone, String status) async {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phone,
      'status': status.toLowerCase(), 
    };
    await remoteDataSource.updateUser(userId, data);
  }

  Future<void> updateAdminProfile({
    required String firstName,
    required String lastName,
    File? imageFile, // Changed: Add optional image file
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in.");

    // 1. Update Text Data
    final data = {
      'first_name': firstName,
      'last_name': lastName,
    };
    await remoteDataSource.updateAdminProfile(user.uid, data);

    // 2. Update Image if provided
    if (imageFile != null) {
      await remoteDataSource.uploadAdminImage(user.uid, imageFile);
    }
  }

  Future<Uint8List?> getAdminImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final base64String = await remoteDataSource.fetchAdminImageBase64(user.uid);
    if (base64String == null) return null;
    
    return base64Decode(base64String);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No user logged in");
    }

    if (user.email == null) {
      throw Exception("User does not have an email linked.");
    }

    try {
      // 1. Create credential with the CURRENT password to prove identity
      final cred = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Re-authenticate (Required by Firebase for sensitive ops)
      await user.reauthenticateWithCredential(cred);

      // 3. Update to NEW password
      await user.updatePassword(newPassword);
      
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('The current password provided is incorrect.');
      } else if (e.code == 'weak-password') {
        throw Exception('The new password is too weak.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Please log out and log back in to change your password.');
      }
      throw Exception(e.message ?? 'Failed to change password.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}