import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart';
import 'package:myfin/core/utils/image_chunker_service.dart';

abstract class ProfileRemoteDataSource {
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfileModel profile);
  Future<void> uploadProfileImage(String memberId, File imageFile);
  Future<String?> fetchProfileImageBase64(String memberId);
  Future<void> uploadBusinessLogo(String profileId, File imageFile);
  Future<String?> fetchBusinessLogoBase64(String profileId);
  Future<void> deleteAccount(String password);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    try {
      await _firestore
          .collection('business_profiles')
          .doc(profile.profileId.isEmpty ? profile.memberId : profile.profileId)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Firestore Error: $e");
    }
  }

  @override
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId) async {
    if (memberId.isEmpty) {
      return BusinessProfileModel(
        profileId: '',
        name: '',
        registrationNo: '',
        contactNo: '',
        email: '',
        address: '',
        memberId: '',
      );
    }

    try {
      final querySnapshot = await _firestore
          .collection('business_profiles')
          .where('member_id', isEqualTo: memberId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return BusinessProfileModel.fromMap(querySnapshot.docs.first.data());
      } else {
        return BusinessProfileModel(
          profileId: '',
          name: '',
          registrationNo: '',
          contactNo: '',
          email: '',
          address: '',
          memberId: memberId,
        );
      }
    } catch (e) {
      throw Exception("Firestore Fetch Business Error: $e");
    }
  }

  @override
  Future<void> uploadProfileImage(String memberId, File imageFile) async {
    try {
      final base64String = await ImageChunkerService.fileToBase64(imageFile);
      final chunks = ImageChunkerService.splitString(base64String);

      final collectionRef = _firestore
          .collection('members')
          .doc(memberId)
          .collection('profile_image_chunks');

      final existingDocs = await collectionRef.get();
      final batchDelete = _firestore.batch();
      for (var doc in existingDocs.docs) {
        batchDelete.delete(doc.reference);
      }
      await batchDelete.commit();

      final batchWrite = _firestore.batch();

      for (int i = 0; i < chunks.length; i++) {
        final docRef = collectionRef.doc(i.toString());
        batchWrite.set(docRef, {
          'index': i,
          'data': chunks[i],
          'total_chunks': chunks.length,
        });
      }

      batchWrite.update(_firestore.collection('members').doc(memberId), {
        'has_custom_image': true,
        'image_updated_at': FieldValue.serverTimestamp(),
      });

      await batchWrite.commit();
    } catch (e) {
      throw Exception("Failed to upload image chunks: $e");
    }
  }

  @override
  Future<String?> fetchProfileImageBase64(String memberId) async {
    try {
      final collectionRef = _firestore
          .collection('members')
          .doc(memberId)
          .collection('profile_image_chunks');

      final querySnapshot = await collectionRef.orderBy('index').get();

      if (querySnapshot.docs.isEmpty) return null;

      final StringBuffer buffer = StringBuffer();
      for (var doc in querySnapshot.docs) {
        buffer.write(doc['data'] as String);
      }

      return buffer.toString();
    } catch (e) {
      throw Exception("Failed to fetch image chunks: $e");
    }
  }

  @override
  Future<void> uploadBusinessLogo(String profileId, File imageFile) async {
    try {
      final base64String = await ImageChunkerService.fileToBase64(imageFile);

      final chunks = ImageChunkerService.splitString(base64String);

      final collectionRef = _firestore
          .collection('business_profiles')
          .doc(profileId)
          .collection('logo_chunks');

      final existingDocs = await collectionRef.get();
      final batchDelete = _firestore.batch();
      for (var doc in existingDocs.docs) {
        batchDelete.delete(doc.reference);
      }
      await batchDelete.commit();

      final batchWrite = _firestore.batch();

      for (int i = 0; i < chunks.length; i++) {
        final docRef = collectionRef.doc(i.toString());
        batchWrite.set(docRef, {
          'index': i,
          'data': chunks[i],
          'total_chunks': chunks.length,
        });
      }

      batchWrite.update(
        _firestore.collection('business_profiles').doc(profileId),
        {
          'has_custom_logo': true,
          'logo_updated_at': FieldValue.serverTimestamp(),
        },
      );

      await batchWrite.commit();
    } catch (e) {
      throw Exception("Failed to upload business logo chunks: $e");
    }
  }

  @override
  Future<String?> fetchBusinessLogoBase64(String profileId) async {
    if (profileId.isEmpty) return null;

    try {
      final collectionRef = _firestore
          .collection('business_profiles')
          .doc(profileId)
          .collection('logo_chunks');

      final querySnapshot = await collectionRef.orderBy('index').get();

      if (querySnapshot.docs.isEmpty) return null;

      final StringBuffer buffer = StringBuffer();
      for (var doc in querySnapshot.docs) {
        buffer.write(doc['data'] as String);
      }

      return buffer.toString();
    } catch (e) {
      throw Exception("Failed to fetch business logo chunks: $e");
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("No user found.");
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);

      await _firestore.collection('members').doc(user.uid).delete();

      await _firestore.collection('business_profiles').doc(user.uid).delete();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception(
          'Please log out and log in again to delete your account.',
        );
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception("Delete Error: $e");
    }
  }
}
