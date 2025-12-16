import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart'; // Import
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final String memberId;
  const LoadProfileEvent(this.memberId);
  @override
  List<Object?> get props => [memberId];
}

class UpdateBusinessProfileEvent extends ProfileEvent {
  final BusinessProfile profile;
  const UpdateBusinessProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

// Added: Update Member Event
class UpdateMemberProfileEvent extends ProfileEvent {
  final Member member;
  final File? newImageFile; 
  const UpdateMemberProfileEvent(this.member, {this.newImageFile});

  @override
  List<Object?> get props => [member, newImageFile];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordEvent({required this.currentPassword, required this.newPassword});
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class LogoutEvent extends ProfileEvent {}