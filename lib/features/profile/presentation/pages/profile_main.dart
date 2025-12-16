import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/core/navigation/app_routes.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.isLoading && state.member == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Correctly get ID from Firebase Auth, NOT hardcoded
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context.read<ProfileBloc>().add(
                              LoadProfileEvent(user.uid),
                            );
                          }
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (state.member != null) {
                return _buildContent(context, state.member!);
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Member member) {
    final List<BoxShadow> commonShadow = [
      const BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];

    // Access the ProfileBloc state to get the image bytes
    final state = context.read<ProfileBloc>().state;
    final Uint8List? imageBytes = state.profileImageBytes;

    // Determine which image provider to use
    final ImageProvider avatarImage = (imageBytes != null)
        ? MemoryImage(imageBytes)
        : const NetworkImage(
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
              )
              as ImageProvider;

    // Get business profile from state to display in the card
    final businessProfile = context.read<ProfileBloc>().state.businessProfile;
    final companyName =
        (businessProfile != null && businessProfile.name.isNotEmpty)
        ? businessProfile.name
        : "No Company Set";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Profile Info Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: commonShadow,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          image: DecorationImage(
                            image: avatarImage, // Use the dynamic provider
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${member.first_name} ${member.last_name}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.email,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.phone_number,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      _buildSimpleRow(Icons.apartment_outlined, companyName),
                      const SizedBox(height: 12),
                      _buildSimpleRow(
                        Icons.location_on_outlined,
                        member.address.isNotEmpty
                            ? member.address
                            : "No Address Set",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SETTINGS
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0, left: 4),
            child: Text(
              "SETTINGS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: commonShadow,
            ),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.person_outline,
                  "Manage Account",
                  hasArrow: true,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/profile_details',
                    arguments: member,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                  indent: 50,
                ),
                _buildActionRow(
                  Icons.storefront_outlined,
                  "Switch to Business Profile",
                  hasArrow: true,
                  onTap: () =>
                      Navigator.pushNamed(context, '/business_profile'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SECURITY & ACTIONS (Same as before)
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0, left: 4),
            child: Text(
              "SECURITY",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: commonShadow,
            ),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.lock_outline,
                  "Change Password",
                  hasArrow: true,
                  onTap: () => Navigator.pushNamed(context, '/change_password'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.only(bottom: 10.0, left: 4),
            child: Text(
              "ACTIONS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: commonShadow,
            ),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.admin_panel_settings_outlined,
                  "Admin Dashboard",
                  hasArrow: true,
                  onTap: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/admin_dashboard'),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                  indent: 50,
                ),
                _buildActionRow(
                  Icons.logout_outlined,
                  "Log Out",
                  onTap: () {
                    context.read<ProfileBloc>().add(LogoutEvent());
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                  indent: 50,
                ),
                _buildActionRow(Icons.delete_outline, "Delete Account"),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

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
              fontFamily: 'Inter',
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String text, {
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
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
                  fontFamily: 'Inter',
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
