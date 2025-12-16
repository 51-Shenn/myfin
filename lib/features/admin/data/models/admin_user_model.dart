import 'package:myfin/features/admin/domain/entities/admin.dart';

class AdminUserModel extends AdminUserView {
  AdminUserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.status,
    required super.imageUrl,
  });

  // Factory to convert JSON (from Firebase/API) to Object
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      userId: json['id'] ?? '',
      name: json['username'] ?? 'Unknown', // Mapping 'username' to 'name'
      email: json['email'] ?? '',
      status: json['status'] ?? 'Active',
      imageUrl: json['profile_image'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
    );
  }

  // Convert Object to JSON (for sending data back)
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'username': name,
      'email': email,
      'status': status,
      'profile_image': imageUrl,
    };
  }
}