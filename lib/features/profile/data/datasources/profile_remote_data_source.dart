import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/authentication/data/models/member_model.dart'; // Import MemberModel
import 'package:myfin/features/profile/data/models/business_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfileModel profile);
  // Added: Update Member
  Future<void> updateMemberProfile(MemberModel member);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    try {
      // Use set with merge true to create if not exists or update
      await _firestore
          .collection('business_profiles')
          .doc(profile.profileId.isEmpty ? profile.memberId : profile.profileId) // Fallback ID strategy
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Firestore Error: $e");
    }
  }

  @override
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection('business_profiles')
          .where('member_id', isEqualTo: memberId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return BusinessProfileModel.fromMap(querySnapshot.docs.first.data());
      } else {
        // Return empty model instead of throwing to allow creation
        return BusinessProfileModel(
            profileId: '',
            name: '',
            registrationNo: '',
            contactNo: '',
            email: '',
            address: '',
            memberId: memberId);
      }
    } catch (e) {
      throw Exception("Firestore Fetch Error: $e");
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
}