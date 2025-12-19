import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_event.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_state.dart';
import 'package:myfin/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/admin/presentation/widgets/edit_user_dialog.dart';
import 'package:myfin/features/admin/presentation/widgets/user_avatar.dart';
import 'package:myfin/features/admin/presentation/widgets/add_admin_dialog.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(
        AdminRepository(remoteDataSource: AdminRemoteDataSourceImpl()),
      )..add(LoadAdminDashboardEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'User Management',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Inter',
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            return FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFF2B46F9),
              onPressed: () {
                showDialog(
                  context: ctx,
                  builder: (dialogContext) {
                    return const AddAdminDialog();
                  },
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminError) {
              return Center(child: Text(state.message));
            }
            if (state is AdminLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) =>
                          context.read<AdminBloc>().add(SearchUsersEvent(val)),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email or ID...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.people_outline,
                            "${state.stats['total']}",
                            "TOTAL USERS",
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.person_add_alt,
                            "${state.stats['new']}",
                            "NEW TODAY",
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.block,
                            "${state.stats['banned']}",
                            "BANNED",
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: ListView.separated(
                        itemCount: state.filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = state.filteredUsers[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                UserAvatar(
                                  userId: user.userId,
                                  userName: user.name,
                                  size: 50,
                                ),
                                const SizedBox(width: 16),
                                // Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: user.status == 'Active'
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        user.status,
                                        style: TextStyle(
                                          color: user.status == 'Active'
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return BlocProvider.value(
                                            value: context.read<AdminBloc>(),
                                            child: EditUserDialog(user: user),
                                          );
                                        },
                                      );
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Delete User"),
                                          content: Text(
                                            "Are you sure you want to delete ${user.name}?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context.read<AdminBloc>().add(
                                                  DeleteUserEvent(user.userId),
                                                );
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "User deleted",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}