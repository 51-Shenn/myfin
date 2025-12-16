import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:myfin/features/authentication/data/models/member_model.dart';
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
    return await remoteDataSource.fetchBusinessProfile(memberId);
  }

  @override
  Future<void> updateMemberProfile(Member member) async {
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
    // Now fetches actual data from Firestore
    return await remoteDataSource.fetchMemberProfile(memberId);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    // This usually requires FirebaseAuth interaction which might belong in AuthRepository,
    // but if you keep it here for UI convenience:
    // await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(...)
    // await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
    await Future.delayed(const Duration(seconds: 1)); // Placeholder logic kept
  }

  @override
  Future<void> uploadProfileImage(String memberId, File imageFile) async {
    await remoteDataSource.uploadProfileImage(memberId, imageFile);
  }

  @override
  Future<Uint8List?> getProfileImage(String memberId) async {
    final base64String = await remoteDataSource.fetchProfileImageBase64(memberId);
    if (base64String == null) return null;
    return base64Decode(base64String);
  }
}