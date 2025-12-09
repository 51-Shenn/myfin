class Member {
  final String memberId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;
  final String status;

  Member({
    required this.memberId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
}