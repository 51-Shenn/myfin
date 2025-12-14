import 'package:myfin/features/authentication/domain/entities/member.dart';

class ProfileRepository {
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Member> fetchMemberProfile(String memberId) async {
    await _delay();
    
    return Member(
      member_id: memberId,
      username: "Username", // Matches image
      first_name: "User",
      last_name: "Name",
      email: "username@gmail.com",
      phone_number: "+60 123456789",
      address: "12, Jalan Danau Saujana",
      created_at: DateTime.now(),
      status: "Active",
    );
  }
}