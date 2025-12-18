import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';

class UserAvatar extends StatefulWidget {
  final String userId;
  final String userName;
  final double size;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.userName,
    this.size = 50,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late Future<Uint8List?> _imageFuture;
  
  // Reuse the existing Repository logic
  final _profileRepository = ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceImpl(),
  );

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    // This reuses the exact function used in the Profile Screen
    _imageFuture = _profileRepository.getProfileImage(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<Uint8List?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 15, 
                  height: 15, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ),
              ),
            );
          }

          // 2. Image Found (Uint8List)
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              ),
            );
          }

          // 3. No Image / Error (Show Initials or Placeholder)
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFC0C9FF), // Light blue background
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.userName.isNotEmpty 
                  ? widget.userName[0].toUpperCase() 
                  : '?',
              style: TextStyle(
                color: const Color(0xFF2B46F9),
                fontWeight: FontWeight.bold,
                fontSize: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}