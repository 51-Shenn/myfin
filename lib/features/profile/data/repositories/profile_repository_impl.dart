import 'package:myfin/features/authentication/data/models/member_model.dart'; // Import
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
    final model = BusinessProfileModel.fromEntity(profile);
    await remoteDataSource.saveBusinessProfile(model);
  }

  @override
  Future<BusinessProfile> getBusinessProfile(String memberId) async {
    // Fetches real data now
    return await remoteDataSource.fetchBusinessProfile(memberId);
  }

  @override
  Future<void> updateMemberProfile(Member member) async {
    // Convert Entity to Model
    final model = MemberModel(
      member_id: member.member_id,
      username: member.username,
      first_name: member.first_name,
      last_name: member.last_name,
      email: member.email,
      phone_number: member.phone_number,
      address: member.address,
      created_at: member.created_at,
      status: member.status,
    );
    await remoteDataSource.updateMemberProfile(model);
  }

  @override
  Future<Member> getMemberProfile(String memberId) async {
    // Note: Ideally you should fetch this from Firestore in RemoteDataSource
    // Keeping mock for now based on your previous code, or ensure logic exists
    await Future.delayed(const Duration(milliseconds: 500));
    return Member(
      member_id: memberId,
      username: "Username",
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
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}