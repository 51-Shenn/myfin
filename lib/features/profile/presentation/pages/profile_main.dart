import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        ProfileRepositoryImpl(remoteDataSource: ProfileRemoteDataSourceImpl()),
      )..add(const LoadProfileEvent("M123")),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              // 1. Check for loading (but usually you might want to show content BEHIND a loader if data exists)
              if (state.isLoading && state.member == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Check for Error
              if (state.error != null) {
                return Center(child: Text(state.error!));
              }

              // 3. Show Content
              if (state.member != null) {
                // If loading is true here (reloading), you could show a linear progress bar at the top
                return Stack(
                  children: [
                    _buildContent(context, state.member!),
                    if (state.isLoading)
                      const LinearProgressIndicator(), // Optional: Indication that it's refreshing
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Member member) {
    // Define the consistent shadow style used in other pages
    final List<BoxShadow> commonShadow = [
      const BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];

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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 1. Profile Info Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20,
              ), // Softer corners like Reports
              boxShadow: commonShadow, // Consistent shadow
              // Removed Border.all
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
                              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                            ),
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
                              fontFamily: 'Inter',
                              color: Colors.black,
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
                    ],
                  ),
                ),

                // Divider
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                // Bottom Section (Company & Address)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      _buildSimpleRow(Icons.apartment_outlined, "Company Inc."),
                      const SizedBox(height: 12),
                      _buildSimpleRow(
                        Icons.location_on_outlined,
                        member.address,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. Settings Section
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
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile_details',
                      arguments: member,
                    );
                  },
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
                  onTap: () {
                    Navigator.pushNamed(context, '/business_profile');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

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
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/change_password',
                      arguments: context
                          .read<ProfileBloc>(), // Pass the BLOC here
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. Actions Section
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
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pushNamed('/admin_dashboard');
                  },
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
                  onTap: () => context.read<ProfileBloc>().add(LogoutEvent()),
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
              fontFamily: 'Inter',
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Helper for Settings/Actions List rows
  Widget _buildActionRow(
    IconData icon,
    String text, {
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        20,
      ), // Ripple effect matches container
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
