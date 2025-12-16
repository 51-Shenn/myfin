import 'dart:io';
import 'dart:typed_data';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

abstract class ProfileRepository {
  Future<Member> getMemberProfile(String memberId);
  Future<BusinessProfile> getBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfile profile);
  Future<void> updateMemberProfile(Member member);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> uploadProfileImage(String memberId, File imageFile);
  Future<Uint8List?> getProfileImage(String memberId);
}