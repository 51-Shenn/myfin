import 'dart:io';
import 'dart:typed_data';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

abstract class ProfileRepository {
  Future<BusinessProfile> getBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfile profile);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> uploadProfileImage(String memberId, File imageFile);
  Future<Uint8List?> getProfileImage(String memberId);
  Future<void> uploadBusinessLogo(String profileId, File imageFile);
  Future<Uint8List?> getBusinessLogo(String profileId);
  Future<void> updateEmail(String newEmail, String currentPassword);
  Future<void> changeEmail(String newEmail, String currentPassword);
  Future<void> deleteAccount(String password);
}