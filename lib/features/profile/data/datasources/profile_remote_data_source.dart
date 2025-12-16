import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/authentication/data/models/member_model.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart';
import 'package:myfin/core/utils/image_chunker_service.dart';

abstract class ProfileRemoteDataSource {
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfileModel profile);

  // Member methods
  Future<MemberModel> fetchMemberProfile(String memberId);
  Future<void> updateMemberProfile(MemberModel member);

  // --- ADDED THESE METHODS ---
  Future<void> uploadProfileImage(String memberId, File imageFile);
  Future<String?> fetchProfileImageBase64(String memberId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // ... (rest of the implementation remains the same)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<MemberModel> fetchMemberProfile(String memberId) async {
    if (memberId.isEmpty) {
      throw Exception("Invalid User ID");
    }

    try {
      final docSnapshot = await _firestore
          .collection('members')
          .doc(memberId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return MemberModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      } else {
        throw Exception(
          "Member profile not found in database for ID: $memberId",
        );
      }
    } catch (e) {
      throw Exception("Firestore Fetch Member Error: $e");
    }
  }

  @override
  Future<void> updateMemberProfile(MemberModel member) async {
    try {
      await _firestore
          .collection('members')
          .doc(member.member_id)
          .update(member.toJson());
    } catch (e) {
      throw Exception("Firestore Member Update Error: $e");
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
}