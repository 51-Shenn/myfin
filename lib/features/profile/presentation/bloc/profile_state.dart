import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

class ProfileState {
  final bool isLoading;
  final Member? member;
  final BusinessProfile? businessProfile;
  final String? error;

  const ProfileState({
    required this.isLoading,
    this.member,
    this.businessProfile,
    this.error,
  });

  // Initial state
  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      member: null,
      businessProfile: null,
      error: null,
    );
  }

  // CopyWith method to update specific fields while keeping others
   ProfileState copyWith({
    bool? isLoading,
    Member? member,
    BusinessProfile? businessProfile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      member: member ?? this.member,
      businessProfile: businessProfile ?? this.businessProfile,
      error: error,
    );
  }
}