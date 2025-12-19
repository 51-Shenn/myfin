import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';

class AdminUserModel extends AdminUserView {
  AdminUserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.status,
    required super.imageUrl,
  });

  factory AdminUserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String displayName = data['username'] ?? 'Unknown';
    if (data['first_name'] != null && data['last_name'] != null) {
      displayName = "${data['first_name']} ${data['last_name']}";
    }

    String rawStatus = data['status'] ?? 'active';
    String formattedStatus = rawStatus[0].toUpperCase() + rawStatus.substring(1);

    return AdminUserModel(
      userId: doc.id,
      name: displayName,
      email: data['email'] ?? '',
      status: formattedStatus,
      imageUrl: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'username': name,
      'email': email,
      'status': status.toLowerCase(),
    };
  }
}