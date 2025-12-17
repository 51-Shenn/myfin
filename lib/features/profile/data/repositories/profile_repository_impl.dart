import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:myfin/features/authentication/data/models/member_model.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/data/models/business_profile.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; 

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
    return await remoteDataSource.fetchMemberProfile(memberId);
  }

  @override
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

  @override
  Future<void> uploadBusinessLogo(String profileId, File imageFile) async {
    await remoteDataSource.uploadBusinessLogo(profileId, imageFile);
  }

  @override
  Future<Uint8List?> getBusinessLogo(String profileId) async {
    final base64String = await remoteDataSource.fetchBusinessLogoBase64(profileId);
    if (base64String == null) return null;
    return base64Decode(base64String);
  }
}