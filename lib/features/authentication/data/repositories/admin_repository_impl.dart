import 'package:myfin/features/authentication/domain/entities/admin.dart';
import 'package:myfin/features/authentication/data/models/admin_model.dart';
import 'package:myfin/features/authentication/domain/repositories/admin_repository.dart';
import 'package:myfin/features/authentication/data/datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remote;

  AdminRepositoryImpl(this.remote);

  @override
  Future<void> createAdmin(Admin admin) {
    final model = AdminModel(
      admin_id: admin.admin_id,
      username: admin.username,
      first_name: admin.first_name,
      last_name: admin.last_name,
      email: admin.email,
      created_at: admin.created_at,
      status: admin.status,
    );
    return remote.createAdmin(model);
  }

  @override
  Future<Admin> getAdmin(String id) async {
    return await remote.getAdmin(id);
  }

  @override
  Future<List<Admin>> getAllAdmins() async {
    return await remote.getAllAdmins();
  }

  @override
  Future<void> updateAdmin(Admin admin) {
    final model = AdminModel(
      admin_id: admin.admin_id,
      username: admin.username,
      first_name: admin.first_name,
      last_name: admin.last_name,
      email: admin.email,
      created_at: admin.created_at,
      status: admin.status,
    );
    return remote.updateAdmin(model);
  }

  @override
  Future<void> deleteAdmin(String id) {
    return remote.deleteAdmin(id);
  }
}
