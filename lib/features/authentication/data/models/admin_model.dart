import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myfin/features/authentication/domain/entities/admin.dart';

class AdminModel extends Admin with EquatableMixin {
  AdminModel({
    required super.admin_id,
    required super.username,
    required super.first_name,
    required super.last_name,
    required super.email,
    required super.created_at,
    required super.status,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json, String id) {
    return AdminModel(
      admin_id: id,
      username: json['username'] ?? '',
      first_name: json['first_name'] ?? '',
      last_name: json['last_name'] ?? '',
      email: json['email'] ?? '',
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
      'created_at': Timestamp.fromDate(created_at), // store as Timestamp
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        admin_id,
        username,
        first_name,
        last_name,
        email,
        created_at,
        status
      ];
}
