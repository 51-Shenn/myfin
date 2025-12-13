import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

abstract class ProfileRepository {
  Future<Member> getMemberProfile(String memberId);
  Future<BusinessProfile> getBusinessProfile(String memberId);
  Future<void> saveBusinessProfile(BusinessProfile profile);
}