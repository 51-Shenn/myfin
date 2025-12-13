import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/authentication/data/models/member_model.dart';

abstract class MemberRemoteDataSource {
  Future<void> createMember(MemberModel member);
  Future<MemberModel> getMember(String memberId);
  Future<List<MemberModel>> getAllMembers();
  Future<void> updateMember(MemberModel member);
  Future<void> deleteMember(String memberId);
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final FirebaseFirestore firestore;

  MemberRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createMember(MemberModel member) async {
    await firestore
        .collection('members')
        .doc(member.member_id)
        .set(member.toJson());
  }

  @override
  Future<MemberModel> getMember(String memberId) async {
    final doc = await firestore.collection('members').doc(memberId).get();

    if (!doc.exists) {
      throw Exception("Member not found");
    }

    return MemberModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<List<MemberModel>> getAllMembers() async {
    final query = await firestore.collection('members').get();
    return query.docs.map((e) => MemberModel.fromJson(e.data(), e.id)).toList();
  }

  @override
  Future<void> updateMember(MemberModel member) async {
    await firestore
        .collection('members')
        .doc(member.member_id)
        .update(member.toJson());
  }

  @override
  Future<void> deleteMember(String memberId) async {
    await firestore.collection('members').doc(memberId).update({
      'status': 'deleted',
    });
  }
}
