import 'package:myfin/features/profile/domain/entities/business_profile.dart';

class BusinessProfileModel extends BusinessProfile {
  BusinessProfileModel({
    required super.profileId,
    required super.name,
    required super.registrationNo,
    required super.contactNo,
    required super.email,
    required super.address,
    required super.memberId,
  });

  factory BusinessProfileModel.fromEntity(BusinessProfile entity) {
    return BusinessProfileModel(
      profileId: entity.profileId,
      name: entity.name,
      registrationNo: entity.registrationNo,
      contactNo: entity.contactNo,
      email: entity.email,
      address: entity.address,
      memberId: entity.memberId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'name': name,
      'registration_no': registrationNo,
      'contact_no': contactNo,
      'email': email,
      'address': address,
      'member_id': memberId,
    };
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map) {
    return BusinessProfileModel(
      profileId: map['profile_id'] ?? '',
      name: map['name'] ?? '',
      registrationNo: map['registration_no'] ?? '',
      contactNo: map['contact_no'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      memberId: map['member_id'] ?? '',
    );
  }
}