import 'package:equatable/equatable.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';

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
  
  // Optional: Add specific action states if you want to show a spinner on a specific row
  // final String? processingUserId; 

  AdminLoaded({
    required this.admin,
    required this.users,
    required this.filteredUsers,
    required this.stats,
  });

  AdminLoaded copyWith({
    Admin? admin,
    List<AdminUserView>? users,
    List<AdminUserView>? filteredUsers,
    Map<String, int>? stats,
  }) {
    return AdminLoaded(
      admin: admin ?? this.admin,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [admin, users, filteredUsers, stats];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
