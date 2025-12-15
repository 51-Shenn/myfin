class Member {
  final String member_id;
  final String username;
  final String first_name;
  final String last_name;
  final String email;
  final String phone_number;
  final String address;
  final DateTime created_at;
  final String status;

  Member({
    required this.member_id,
    required this.username,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.phone_number,
    required this.address,
    required this.created_at,
    required this.status,
  });

  @override
  String toString() {
    return 'Member(ID: $member_id, Username: $username, First Name: $first_name, Last Name: $last_name, Email: $email, Phone Number: $phone_number, Address: $address, Created At: $created_at, Status: $status)';
  }
}