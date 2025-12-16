import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<BusinessProfileModel> fetchBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    try {
      await _firestore
          .collection('business_profiles')
          .doc(profile.profileId)
          .set(profile.toMap());
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
        throw Exception("Profile not found");
      }
    } catch (e) {
      throw Exception("Firestore Fetch Error: $e");
    }
  }
}