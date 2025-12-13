import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/authentication/data/models/member_model.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
import 'package:myfin/features/authentication/data/datasources/member_remote_data_source.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remote;

  MemberRepositoryImpl(this.remote);

  @override
  Future<void> createMember(Member member) {
    final model = MemberModel(
      member_id: member.member_id,
      username: member.username,
      first_name: member.first_name,
      last_name: member.last_name,
      email: member.email,
      phone_number: member.phone_number,
      address: member.address,
      created_at: member.created_at,
      status: member.status,
    );
    return remote.createMember(model);
  }

  @override
  Future<Member> getMember(String id) async {
    return await remote.getMember(id);
  }

  @override
  Future<List<Member>> getAllMembers() async {
    return await remote.getAllMembers();
  }

  @override
  Future<void> updateMember(Member member) {
    final model = MemberModel(
      member_id: member.member_id,
      username: member.username,
      first_name: member.first_name,
      last_name: member.last_name,
      email: member.email,
      phone_number: member.phone_number,
      address: member.address,
      created_at: member.created_at,
      status: member.status,
    );
    return remote.updateMember(model);
  }

  @override
  Future<void> deleteMember(String id) {
    return remote.deleteMember(id);
  }
}
