import 'package:myfin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';

class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  Future<Admin> getAdminDetails() async {
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
    return await remoteDataSource.fetchUsers();
  }

  Future<Map<String, int>> getStats() async {
    return await remoteDataSource.fetchStats();
  }

  Future<void> banUser(String userId, String currentStatus) async {
    await remoteDataSource.banUser(userId, currentStatus);
  }

  Future<void> deleteUser(String userId) async {
    await remoteDataSource.deleteUser(userId);
  }

  Future<void> updateUser(String userId, String firstName, String lastName, String email, String phone, String status) async {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phone,
      'status': status.toLowerCase(), 
    };
    await remoteDataSource.updateUser(userId, data);
  }
}