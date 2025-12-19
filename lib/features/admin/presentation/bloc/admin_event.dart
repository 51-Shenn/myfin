import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAdminDashboardEvent extends AdminEvent {}

class SearchUsersEvent extends AdminEvent {
  final String query;
  SearchUsersEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class BanUserEvent extends AdminEvent {
  final String userId;
  BanUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class DeleteUserEvent extends AdminEvent {
  final String userId;
  DeleteUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class EditUserEvent extends AdminEvent {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String status;

  EditUserEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, email, phoneNumber, status];
}

// --- NEW EVENTS ---

class UpdateAdminProfileEvent extends AdminEvent {
  final String firstName;
  final String lastName;
  final File? imageFile;

  UpdateAdminProfileEvent({
    required this.firstName,
    required this.lastName,
    this.imageFile,
  });

  @override
  List<Object?> get props => [firstName, lastName, imageFile];
}

class AdminChangePasswordEvent extends AdminEvent {
  final String currentPassword;
  final String newPassword;

  AdminChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}