import 'package:equatable/equatable.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Event to trigger loading the member and business profile
class LoadProfileEvent extends ProfileEvent {
  final String memberId;

  const LoadProfileEvent(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

// Event to trigger a profile update
class UpdateBusinessProfileEvent extends ProfileEvent {
  final BusinessProfile profile;

  const UpdateBusinessProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword, 
    required this.newPassword
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// Event to trigger logout
class LogoutEvent extends ProfileEvent {}
