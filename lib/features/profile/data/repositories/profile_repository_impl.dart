import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    // Convert Entity -> Model
    final model = BusinessProfileModel.fromEntity(profile);
    await remoteDataSource.saveBusinessProfile(model);
  }

  @override
  Future<BusinessProfile> getBusinessProfile(String memberId) async {
    try {
      // Try fetching real data
      final model = await remoteDataSource.fetchBusinessProfile(memberId);
      return model; // Model extends Entity, so this works
    } catch (e) {
      // FALLBACK: If no data found in Firebase (or error), return your Mock Data
      // This mimics your previous logic to keep the UI working
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
  }

  @override
  Future<Member> getMemberProfile(String memberId) async {
    // Currently you are mocking this.
    // In the future, you would call remoteDataSource.fetchMember(memberId)
    await Future.delayed(const Duration(milliseconds: 500));
    return Member(
      member_id: memberId,
      username: "Username", // Matches image
      first_name: "User",
      last_name: "Name",
      email: "username@gmail.com",
      phone_number: "+60 123456789",
      address: "12, Jalan Danau Saujana",
      created_at: DateTime.now(),
      status: "Active",
    );
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // TODO: Implement actual Firebase/Backend logic here
    // Example: await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);

    // Simulating delay for now
    await Future.delayed(const Duration(seconds: 1));

    // Simulating a check (remove this in real app)
    if (currentPassword == "wrong") {
      throw Exception("Current password is incorrect");
    }
  }
}
