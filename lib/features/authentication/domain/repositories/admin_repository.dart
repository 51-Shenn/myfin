
import 'package:myfin/features/authentication/domain/entities/admin.dart';

abstract class AdminRepository {
  Future<void> createAdmin(Admin admin);
  Future<Admin> getAdmin(String id);
  Future<List<Admin>> getAllAdmins();
  Future<void> updateAdmin(Admin admin);
  Future<void> deleteAdmin(String id);
}