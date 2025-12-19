class BusinessProfile {
  final String profileId;
  final String name;
  final String registrationNo;
  final String contactNo;
  final String email;
  final String address;
  final String memberId;

  BusinessProfile({
    required this.profileId,
    required this.name,
    required this.registrationNo,
    required this.contactNo,
    required this.email,
    required this.address,
    required this.memberId,
  });

  factory BusinessProfile.empty() {
    return BusinessProfile(
      profileId: '',
      name: '',
      registrationNo: '',
      contactNo: '',
      email: '',
      address: '',
      memberId: '',
    );
  }
}
