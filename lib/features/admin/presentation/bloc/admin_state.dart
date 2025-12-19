import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';

enum AdminPasswordStatus { initial, loading, success, failure }

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final Admin admin;
  final List<AdminUserView> users;
  final List<AdminUserView> filteredUsers;
  final Map<String, int> stats;
  final Uint8List? adminImageBytes;
  final AdminPasswordStatus passwordStatus;
  final String? passwordError;

  AdminLoaded({
    required this.admin,
    required this.users,
    required this.filteredUsers,
    required this.stats,
    this.adminImageBytes,
    this.passwordStatus = AdminPasswordStatus.initial,
    this.passwordError,
  });

  AdminLoaded copyWith({
    Admin? admin,
    List<AdminUserView>? users,
    List<AdminUserView>? filteredUsers,
    Map<String, int>? stats,
    Uint8List? adminImageBytes,
    AdminPasswordStatus? passwordStatus,
    String? passwordError,
  }) {
    return AdminLoaded(
      admin: admin ?? this.admin,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      stats: stats ?? this.stats,
      adminImageBytes: adminImageBytes ?? this.adminImageBytes,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      passwordError: passwordError ?? this.passwordError,
    );
  }

  @override
  List<Object?> get props => [
    admin,
    users,
    filteredUsers,
    stats,
    adminImageBytes,
    passwordStatus,
    passwordError,
  ];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}