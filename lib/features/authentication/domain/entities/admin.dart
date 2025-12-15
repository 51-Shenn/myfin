class Admin {
  final String admin_id;
  final String username;
  final String first_name;
  final String last_name;
  final String email;
  final DateTime created_at;
  final String status;

  Admin({
    required this.admin_id,
    required this.username,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.created_at,
    required this.status,
  });

  @override
  String toString() {
    return 'Admin(ID: $admin_id, Username: $username, First Name: $first_name, Last Name: $last_name, Email: $email, Created At: $created_at, Status: $status)';
  }
}