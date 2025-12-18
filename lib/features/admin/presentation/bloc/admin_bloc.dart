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

      // Find user to get current status
      final userToBan = currentState.users.firstWhere((u) => u.userId == event.userId);

      try {
        // Call Repo (Real Firebase Call)
        await _repo.banUser(event.userId, userToBan.status);

        // Calculate new status for local update
        final newStatus = userToBan.status == 'Active' ? 'Banned' : 'Active';

        // Update Local State
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

        // Update stats locally (simple +/- 1 adjustment)
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
            filteredUsers: updatedUsers, // Or re-apply filter
            stats: newStats,
          ),
        );
      } catch (e) {
        // Handle error (maybe emit side effect, but for now stick to state)
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
        // Call Repo (Real Firebase Call)
        await _repo.deleteUser(event.userId);

        // Remove from local lists
        final updatedUsers = currentState.users
            .where((user) => user.userId != event.userId)
            .toList();
        
        // Update stats
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
        // 1. Call Repo to update Firestore
        await _repo.updateUser(
          event.userId, 
          event.firstName, 
          event.lastName, 
          event.email, 
          event.phoneNumber, 
          event.status
        );

        // 2. Update Local State to reflect changes immediately
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
}