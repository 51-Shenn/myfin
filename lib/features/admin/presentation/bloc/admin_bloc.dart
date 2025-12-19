import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_event.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  AdminBloc(this._repo) : super(AdminLoading()) {
    on<LoadAdminDashboardEvent>(_onLoadDashboard);
    on<SearchUsersEvent>(_onSearchUsers);
    on<BanUserEvent>(_onBanUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<EditUserEvent>(_onEditUser);
    on<UpdateAdminProfileEvent>(_onUpdateProfile);
    on<AdminChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboardEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        _repo.getAdminDetails(),
        _repo.getUsers(),
        _repo.getStats(),
        _repo.getAdminImage(),
      ]);

      final admin = results[0] as Admin;
      final users = results[1] as List<AdminUserView>;
      final stats = results[2] as Map<String, int>;
      final imageBytes = results[3] as Uint8List?;

      emit(
        AdminLoaded(
          admin: admin,
          users: users,
          filteredUsers: users,
          stats: stats,
          adminImageBytes: imageBytes,
        ),
      );
    } catch (e) {
      emit(AdminError("Failed to load admin dashboard: $e"));
    }
  }

  void _onSearchUsers(SearchUsersEvent event, Emitter<AdminState> emit) {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;
      final query = event.query.toLowerCase();

      final filtered = currentState.users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.userId.toLowerCase().contains(query);
      }).toList();

      emit(
        AdminLoaded(
          admin: currentState.admin,
          users: currentState.users,
          filteredUsers: filtered,
          stats: currentState.stats,
        ),
      );
    }
  }

  Future<void> _onBanUser(BanUserEvent event, Emitter<AdminState> emit) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      final userToBan = currentState.users.firstWhere(
        (u) => u.userId == event.userId,
      );

      try {
        await _repo.banUser(event.userId, userToBan.status);

        final newStatus = userToBan.status == 'Active' ? 'Banned' : 'Active';

        final updatedUsers = currentState.users.map((user) {
          if (user.userId == event.userId) {
            return AdminUserView(
              userId: user.userId,
              name: user.name,
              email: user.email,
              status: newStatus,
              imageUrl: user.imageUrl,
            );
          }
          return user;
        }).toList();

        final Map<String, int> newStats = Map.from(currentState.stats);
        if (newStatus == 'Banned') {
          newStats['banned'] = (newStats['banned'] ?? 0) + 1;
        } else {
          newStats['banned'] = (newStats['banned'] ?? 1) - 1;
        }

        emit(
          AdminLoaded(
            admin: currentState.admin,
            users: updatedUsers,
            filteredUsers: updatedUsers, 
            stats: newStats,
          ),
        );
      } catch (e) {
        print("Error banning user: $e");
      }
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      try {
        await _repo.deleteUser(event.userId);

        final updatedUsers = currentState.users
            .where((user) => user.userId != event.userId)
            .toList();

        final Map<String, int> newStats = Map.from(currentState.stats);
        newStats['total'] = (newStats['total'] ?? 1) - 1;

        emit(
          AdminLoaded(
            admin: currentState.admin,
            users: updatedUsers,
            filteredUsers: updatedUsers,
            stats: newStats,
          ),
        );
      } catch (e) {
        print("Error deleting user: $e");
      }
    }
  }

  Future<void> _onEditUser(
    EditUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      try {
        await _repo.updateUser(
          event.userId,
          event.firstName,
          event.lastName,
          event.email,
          event.phoneNumber,
          event.status,
        );

        final updatedUsers = currentState.users.map((user) {
          if (user.userId == event.userId) {
            return AdminUserView(
              userId: user.userId,
              name: "${event.firstName} ${event.lastName}",
              email: event.email,
              status: event.status,
              imageUrl: user.imageUrl,
            );
          }
          return user;
        }).toList();

        emit(
          AdminLoaded(
            admin: currentState.admin,
            users: updatedUsers,
            filteredUsers: updatedUsers,
            stats: currentState.stats,
          ),
        );
      } catch (e) {
        print("Error editing user: $e");
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateAdminProfileEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      emit(AdminLoading());

      try {
        await _repo.updateAdminProfile(
          firstName: event.firstName,
          lastName: event.lastName,
          imageFile: event.imageFile,
        );

        add(LoadAdminDashboardEvent());
      } catch (e) {
        emit(AdminError("Failed to update profile: $e"));
      }
    }
  }
  
   Future<void> _onChangePassword(
    AdminChangePasswordEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      emit(currentState.copyWith(
        passwordStatus: AdminPasswordStatus.loading,
        passwordError: null,
      ));

      try {
        await _repo.changePassword(event.currentPassword, event.newPassword);

        emit(currentState.copyWith(
          passwordStatus: AdminPasswordStatus.success,
        ));

        await Future.delayed(const Duration(seconds: 1));
        if (!isClosed) {
           emit(currentState.copyWith(passwordStatus: AdminPasswordStatus.initial));
        }

      } catch (e) {
        emit(currentState.copyWith(
          passwordStatus: AdminPasswordStatus.failure,
          passwordError: e.toString().replaceAll("Exception: ", ""),
        ));
      }
    }
  }
}
