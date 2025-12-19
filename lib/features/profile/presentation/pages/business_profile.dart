import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Business',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.businessProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text("Error: ${state.error}"));
          }

          final business = state.businessProfile;
          final member = state.member;
          final logoBytes = state.businessImageBytes;

          if (business == null && member == null) {
            return const Center(child: Text("Loading profile data..."));
          }

          final displayProfile =
              business ??
              BusinessProfile(
                profileId: '',
                name: 'No Business Name',
                registrationNo: '-',
                contactNo: '-',
                email: '-',
                address: '-',
                memberId: member?.member_id ?? '',
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(displayProfile, logoBytes),
                const SizedBox(height: 30),

                _buildSectionTitle("OFFICIAL DETAILS"),
                _buildDetailsCard(displayProfile),
                const SizedBox(height: 30),

                _buildSectionTitle("SETTINGS"),
                _buildSettingsCard(context, business, member?.member_id),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BusinessProfile business, Uint8List? logoBytes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              image: logoBytes != null
                  ? DecorationImage(
                      image: MemoryImage(logoBytes),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: logoBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.layers_outlined,
                        size: 40,
                        color: Color(0xFF2B46F9),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "LOGO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 24),
          Text(
            business.name.isEmpty ? "Set Company Name" : business.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BusinessProfile business) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.domain,
            title: "Registration No.",
            value: business.registrationNo,
          ),
          _buildDivider(),

          _buildDetailItem(
            icon: Icons.email_outlined,
            title: "Email Address",
            value: business.email,
          ),
          _buildDivider(),

          _buildDetailItem(
            icon: Icons.phone_outlined,
            title: "Contact No.",
            value: business.contactNo,
          ),
          _buildDivider(),

          _buildDetailItem(
            icon: Icons.location_on_outlined,
            title: "Registered Address",
            value: business.address,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    BusinessProfile? business,
    String? memberId,
  ) {
    return Container(
      decoration: _boxDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.person_outline, color: Colors.black),
        title: const Text(
          "Manage Business Profile",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF2B46F9)),
        onTap: () {
          final profileBloc = context.read<ProfileBloc>();

          Navigator.of(context, rootNavigator: true).pushNamed(
            AppRoutes
                .editBusinessProfile, 
            arguments: {
              'profile': business,
              'memberId': memberId ?? '',
              'bloc': profileBloc,
            },
          );
        },
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        const BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 64,
      endIndent: 20,
    );
  }
}
