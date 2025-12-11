import 'package:myfin/features/authentication/domain/entities/member.dart';

class ProfileRepository {
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Member> fetchMemberProfile(String memberId) async {
    await _delay();
    
    return Member(
      memberId: memberId,
      username: "Username", // Matches image
      firstName: "User",
      lastName: "Name",
      email: "username@gmail.com",
      phoneNumber: "+60 123456789",
      address: "12, Jalan Danau Saujana",
      createdAt: DateTime.now(),
      status: "Active",
    );
  }
}