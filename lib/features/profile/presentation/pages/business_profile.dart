import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileViewModel(ProfileRepository())..loadProfile("M123"),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
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
        body: BlocBuilder<ProfileViewModel, ProfileState>(
          builder: (context, state) {
            // 1. Loading State
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (state.error != null) {
              return Center(child: Text("Error: ${state.error}"));
            }

            // 3. Success State
            final business = state.businessProfile;
            
            // If no business profile exists yet
            if (business == null) {
               return const Center(child: Text("No Business Profile Found"));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(business),
                  const SizedBox(height: 30),
                  
                  _buildSectionTitle("OFFICIAL DETAILS"),
                  _buildDetailsCard(business),
                  const SizedBox(height: 30),
                  
                  _buildSectionTitle("SETTINGS"),
                  _buildSettingsCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Dynamic Header Card ---
  Widget _buildHeaderCard(BusinessProfile business) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Column(
            children: [
              const Icon(Icons.layers_outlined, size: 50, color: Color(0xFF2B46F9)),
              const SizedBox(height: 4),
              const Text(
                "COMPANY\nLOGO HERE",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              )
            ],
          ),
          const SizedBox(height: 24),
          // DYNAMIC DATA: Name
          Text(
            business.name,
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

  // --- Dynamic Details Card ---
  Widget _buildDetailsCard(BusinessProfile business) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          // DYNAMIC DATA: Registration No
          _buildDetailItem(
            icon: Icons.domain,
            title: "Registration No.",
            value: business.registrationNo, 
          ),
          _buildDivider(),
          
          // DYNAMIC DATA: Email
          _buildDetailItem(
            icon: Icons.email_outlined,
            title: "Email Address",
            value: business.email,
          ),
          _buildDivider(),
          
          // DYNAMIC DATA: Contact No
          _buildDetailItem(
            icon: Icons.phone_outlined,
            title: "Contact No.",
            value: business.contactNo,
          ),
          _buildDivider(),
          
          // DYNAMIC DATA: Address
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

  Widget _buildSettingsCard() {
    return Container(
      decoration: _boxDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.person_outline, color: Colors.black),
        title: const Text(
          "Manage Business Profile",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF2B46F9)),
        onTap: () {
          // Navigate to edit form
        },
      ),
    );
  }

  // --- Helpers ---

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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
                  value,
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