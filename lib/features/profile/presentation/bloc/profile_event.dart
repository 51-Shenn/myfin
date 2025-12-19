import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
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
  final File? logoFile;
  const UpdateBusinessProfileEvent(this.profile, {this.logoFile});
  @override
  List<Object?> get props => [profile, logoFile];
}

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
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class LogoutEvent extends ProfileEvent {}

class ChangeEmailEvent extends ProfileEvent {
  final String newEmail;
  final String currentPassword;

  const ChangeEmailEvent({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

class DeleteAccountEvent extends ProfileEvent {
  final String password;
  const DeleteAccountEvent(this.password);

  @override
  List<Object?> get props => [password];
}