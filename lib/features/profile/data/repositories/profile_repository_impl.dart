import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart'; // Import Model
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance

  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // --- 1. REAL SAVE FUNCTION ---
  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    try {
      // Convert Entity to Model
      final model = BusinessProfileModel.fromEntity(profile);

      // Save to collection 'business_profiles'
      // .doc(profile.profileId) -> Sets the Document ID to match the profile_id
      // .set(model.toMap()) -> Overwrites/Creates the data
      await _firestore
          .collection('business_profiles')
          .doc(profile.profileId) 
          .set(model.toMap());

      print("Business Profile Saved: ${profile.profileId}");
    } catch (e) {
      print("Error Saving Profile: $e");
      throw Exception("Failed to save business profile");
    }
  }

  // --- 2. HARDCODED READ FUNCTION (Kept as requested) ---
  Future<BusinessProfile> fetchBusinessProfile(String memberId) async {
    await _delay(); // Simulate network delay
    
    // Still returning fake data so your UI works immediately
    return BusinessProfile(
      profileId: "TDqRBG3siDkO2DtldeKo", 
      name: "Eugene Trading Sdn Bhd",
      registrationNo: "202301005921",
      contactNo: "+60123456789",
      email: "eugenetrade@gmail.com",
      address: "13, Taman Bunga Raya, Kuala Lumpur",
      memberId: memberId,
    );
  }

  // ... (Keep your existing fetchMemberProfile here) ...
  Future<Member> fetchMemberProfile(String memberId) async {
    await _delay();
    return Member(
      memberId: memberId,
      username: "Eugene",
      firstName: "Eugene",
      lastName: "Tan",
      email: "eugene@gmail.com",
      phoneNumber: "+60 123456789",
      address: "12, Jalan Danau Saujana",
      createdAt: DateTime.now(),
      status: "Active",
    );
  }
}