import 'dart:typed_data';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

enum FormStatus { initial, submissionInProgress, submissionSuccess, submissionFailure }

class ProfileState {
  final bool isLoading;
  final Member? member;
  final BusinessProfile? businessProfile;
  final String? error;
  final FormStatus passwordStatus;
  final Uint8List? profileImageBytes;

  const ProfileState({
    required this.isLoading,
    this.member,
    this.businessProfile,
    this.error,
    this.passwordStatus = FormStatus.initial,
    this.profileImageBytes,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      member: null,
      businessProfile: null,
      error: null,
      passwordStatus: FormStatus.initial,
      profileImageBytes: null,
    );
  }

  ProfileState copyWith({
    bool? isLoading,
    Member? member,
    BusinessProfile? businessProfile,
    String? error,
    FormStatus? passwordStatus,
    Uint8List? profileImageBytes, // Added parameter
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      member: member ?? this.member,
      businessProfile: businessProfile ?? this.businessProfile,
      error: error, // Keep explicit null handling logic you had or change to ?? this.error
      passwordStatus: passwordStatus ?? this.passwordStatus,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes, // Added assignment
    );
  }
}