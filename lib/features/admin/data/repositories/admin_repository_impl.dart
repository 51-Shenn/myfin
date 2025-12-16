import 'package:myfin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
// Note: We normally define an abstract Repository interface in Domain layer, 
// but for simplicity, we often keep the class here if the app is small.

class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  Future<Admin> getAdminDetails() async {
    // Mocking this part as it usually comes from Auth service
    return Admin(
      adminId: "ADM-001",
      username: "superadmin",
      firstName: "Admin",
      lastName: "User",
      email: "admin@myfin.com",
      createdAt: DateTime.now(),
    );
  }

  Future<List<AdminUserView>> getUsers() async {
    final models = await remoteDataSource.fetchUsers();
    return models; // Models extend Entities, so this is valid.
  }

  Future<Map<String, int>> getStats() async {
    return await remoteDataSource.fetchStats();
  }

  Future<void> banUser(String userId) async {
    await remoteDataSource.banUser(userId);
  }

  Future<void> deleteUser(String userId) async {
    await remoteDataSource.deleteUser(userId);
  }
}