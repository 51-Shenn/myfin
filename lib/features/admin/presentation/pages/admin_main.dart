import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/data/datasources/tax_regulation_remote_data_source.dart';
import 'package:myfin/features/admin/data/repositories/tax_regulation_repository_impl.dart';
import 'package:myfin/features/admin/presentation/cubit/tax_regulation_cubit.dart';
import 'package:myfin/features/admin/presentation/pages/tax_regulations_list_screen.dart';
import 'package:myfin/features/admin/presentation/pages/user_management_screen.dart';
import 'package:myfin/features/admin/presentation/pages/admin_profile_screen.dart'; // Import the new file
import 'package:myfin/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_event.dart';
import 'package:myfin/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/admin/data/datasources/admin_remote_data_source.dart';


class AdminTaxScreen extends StatelessWidget {
  const AdminTaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaxRegulationCubit(
        repository: TaxRegulationRepositoryImpl(
          remoteDataSource: TaxRegulationRemoteDataSource(
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ),
      child: const TaxRegulationsListScreen(),
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  // List of screens for the admin navigation
  final List<Widget> _pages = [
    const UserManagementScreen(), // Tab 0
    const AdminTaxScreen(),       // Tab 1
    
    // Tab 2: Provide the Bloc so the profile can load data
    BlocProvider(
      create: (context) => AdminBloc(
        AdminRepository(remoteDataSource: AdminRemoteDataSourceImpl()),
      )..add(LoadAdminDashboardEvent()),
      child: const AdminProfileScreen(),
    ), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2B46F9),
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_alt_outlined, 0),
              activeIcon: _buildIcon(Icons.people_alt, 0, isActive: true),
              label: 'Manage User',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.description_outlined, 1),
              activeIcon: _buildIcon(Icons.description, 1, isActive: true),
              label: 'Tax Regulations',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_outline, 2),
              activeIcon: _buildIcon(Icons.person, 2, isActive: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create the styled icon background shown in your image
  Widget _buildIcon(IconData icon, int index, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? const BoxDecoration(
              color: Color(0xFF2B46F9), // Blue background for active
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.black,
        size: 24,
      ),
    );
  }
}
