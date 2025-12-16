import 'package:myfin/features/admin/data/models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminUserModel>> fetchUsers();
  Future<void> banUser(String userId);
  Future<void> deleteUser(String userId);
  Future<Map<String, int>> fetchStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Uncomment for real app

  @override
  Future<List<AdminUserModel>> fetchUsers() async {
    // SIMULATED API CALL
    await Future.delayed(const Duration(milliseconds: 800));
    
    // In real app: final snapshot = await _firestore.collection('users').get();
    // return snapshot.docs.map((doc) => AdminUserModel.fromJson(doc.data())).toList();

    return List.generate(10, (index) => AdminUserModel(
      userId: "U-$index",
      name: "User ${index + 1}",
      email: "user${index + 1}@gmail.com",
      status: index % 4 == 0 ? "Banned" : "Active",
      imageUrl: "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
    ));
  }

  @override
  Future<void> banUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Real logic: await _firestore.collection('users').doc(userId).update({'status': 'Banned'});
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Real logic: await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Future<Map<String, int>> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "total": 150,
      "new": 12,
      "banned": 5,
    };
  }
}