class Admin {
  final String adminId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime createdAt;

  Admin({
    required this.adminId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
  });
}

class AdminUserView {
  // ... (Keep existing AdminUserView as is)
  final String userId;
  final String name;
  final String email;
  final String status; 
  final String imageUrl;

  AdminUserView({
    required this.userId,
    required this.name,
    required this.email,
    required this.status,
    required this.imageUrl,
  });
}