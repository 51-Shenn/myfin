import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/repository/profile_repo.dart';
import 'package:myfin/viewmodels/profile_viewmodel.dart';
import 'package:myfin/datamodels/member.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileViewModel(ProfileRepository())..loadProfile("M123"),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<ProfileViewModel, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(child: Text(state.message));
              } else if (state is ProfileLoaded) {
                return _buildContent(context, state.member);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Member member) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Center(
            child: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 1. Profile Info Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Top Section (Avatar + Details)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Text Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                
                // Bottom Section (Company & Address)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      _buildSimpleRow(Icons.apartment_outlined, "Company Inc."), // Hardcoded as per image, or add to model
                      const SizedBox(height: 12),
                      _buildSimpleRow(Icons.location_on_outlined, member.address),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. Settings Section
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "SETTINGS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildActionRow(Icons.person_outline, "Manage Account", hasArrow: true),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200, indent: 50), // Indented divider
                _buildActionRow(Icons.storefront_outlined, "Switch to Business Profile", hasArrow: true),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. Actions Section
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "ACTIONS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.logout_outlined, 
                  "Log Out", 
                  onTap: () => context.read<ProfileViewModel>().logout()
                ),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200, indent: 50),
                _buildActionRow(Icons.delete_outline, "Delete Account"),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper for the Profile Card rows (Company/Address)
  Widget _buildSimpleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Helper for Settings/Actions List rows
  Widget _buildActionRow(IconData icon, String text, {bool hasArrow = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            if (hasArrow)
              const Icon(Icons.chevron_right, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }
}