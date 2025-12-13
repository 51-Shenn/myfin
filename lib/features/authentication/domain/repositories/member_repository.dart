
import 'package:myfin/features/authentication/domain/entities/member.dart';

abstract class MemberRepository {
  Future<void> createMember(Member member);
  Future<Member> getMember(String id);
  Future<List<Member>> getAllMembers();
  Future<void> updateMember(Member member);
  Future<void> deleteMember(String id);
}