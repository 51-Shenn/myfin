import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/authentication/data/models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> createAdmin(AdminModel admin);
  Future<AdminModel> getAdmin(String adminId);
  Future<List<AdminModel>> getAllAdmins();
  Future<void> updateAdmin(AdminModel admin);
  Future<void> deleteAdmin(String adminId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createAdmin(AdminModel admin) async {
    await firestore
        .collection('admins')
        .doc(admin.admin_id)
        .set(admin.toJson());
  }

  @override
  Future<AdminModel> getAdmin(String adminId) async {
    final doc = await firestore.collection('admins').doc(adminId).get();

    if (!doc.exists) {
      throw Exception("Admin not found");
    }

    return AdminModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<List<AdminModel>> getAllAdmins() async {
    final query = await firestore.collection('admins').get();
    return query.docs.map((e) => AdminModel.fromJson(e.data(), e.id)).toList();
  }

  @override
  Future<void> updateAdmin(AdminModel admin) async {
    await firestore
        .collection('admins')
        .doc(admin.admin_id)
        .update(admin.toJson());
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    await firestore.collection('admins').doc(adminId).update({
      'status': 'deleted',
    });
  }
}
