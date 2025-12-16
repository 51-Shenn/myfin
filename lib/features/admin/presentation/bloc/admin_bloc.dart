import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_event.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_state.dart'; // Add this import

// REMOVED: Duplicate AdminEvent and AdminState class definitions.
// They are now imported from their respective files.

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  AdminBloc(this._repo) : super(AdminLoading()) {
    on<LoadAdminDashboardEvent>(_onLoadDashboard);
    on<SearchUsersEvent>(_onSearchUsers);
    on<BanUserEvent>(_onBanUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<EditUserEvent>(_onEditUser);
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
      ]);

      final admin = results[0] as Admin;
      final users = results[1] as List<AdminUserView>;
      final stats = results[2] as Map<String, int>;

      emit(
        AdminLoaded(
          admin: admin,
          users: users,
          filteredUsers: users,
          stats: stats,
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

      // Call Repo
      await _repo.banUser(event.userId);

      // Update Local State (Toggle "Active" <-> "Banned")
      final updatedUsers = currentState.users.map((user) {
        if (user.userId == event.userId) {
          final newStatus = user.status == 'Active' ? 'Banned' : 'Active';
          // Create new user object with updated status
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

      emit(
        AdminLoaded(
          admin: currentState.admin,
          users: updatedUsers,
          filteredUsers: updatedUsers,
          stats: currentState.stats,
        ),
      );
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      // Call Repo
      await _repo.deleteUser(event.userId);

      // Remove from lists
      final updatedUsers = currentState.users
          .where((user) => user.userId != event.userId)
          .toList();

      emit(
        AdminLoaded(
          admin: currentState.admin,
          users: updatedUsers,
          filteredUsers: updatedUsers,
          stats: currentState.stats,
        ),
      );
    }
  }

  Future<void> _onEditUser(
    EditUserEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (state is AdminLoaded) {
      final currentState = state as AdminLoaded;

      // 1. Simulate API Call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Update Local State
      final updatedUsers = currentState.users.map((user) {
        if (user.userId == event.userId) {
          // Reconstruct user with new data
          return AdminUserView(
            userId: user.userId,
            // Combine First and Last name back into one string
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
          filteredUsers: updatedUsers, // Or re-apply search filter if needed
          stats: currentState.stats,
        ),
      );
    }
  }
}
