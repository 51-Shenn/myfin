import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';

class MemberModel extends Member with EquatableMixin {
  MemberModel({
    required super.member_id,
    required super.username,
    required super.first_name,
    required super.last_name,
    required super.email,
    required super.phone_number,
    required super.address,
    required super.created_at,
    required super.status,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json, String id) {
    return MemberModel(
      member_id: id,
      username: json['username'] ?? '',
      first_name: json['first_name'] ?? '',
      last_name: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone_number: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      created_at: json['created_at'] != null
          ? (json['created_at'] is Timestamp
              ? (json['created_at'] as Timestamp).toDate()
              : DateTime.parse(json['created_at']))
          : DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'phone_number': phone_number,
      'address': address,
      'created_at': Timestamp.fromDate(created_at),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        member_id,
        username,
        first_name,
        last_name,
        email,
        phone_number,
        address,
        created_at,
        status
      ];
}
