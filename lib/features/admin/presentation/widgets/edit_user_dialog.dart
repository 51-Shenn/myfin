import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/domain/entities/admin.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:myfin/features/admin/presentation/bloc/admin_event.dart';

class EditUserDialog extends StatefulWidget {
  final AdminUserView user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Active', 'Banned', 'Pending'];

  @override
  void initState() {
    super.initState();
    // Logic to split the full name into First and Last name
    List<String> names = widget.user.name.split(' ');
    String firstName = names.isNotEmpty ? names.first : '';
    String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: widget.user.email);
    // Since phone isn't in AdminUserView yet, we use a placeholder or empty string
    _phoneController = TextEditingController(text: '+60 123456789'); 
    _selectedStatus = widget.user.status;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),

            // First Name & Last Name Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'First Name',
                    controller: _firstNameController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Last Name',
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Email',
              controller: _emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Phone Number',
              controller: _phoneController,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: Colors.black,
                fontFamily: 'Inter'
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusOptions.contains(_selectedStatus) ? _selectedStatus : _statusOptions.first,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontFamily: 'Inter')),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Dispatch Update Event
                  context.read<AdminBloc>().add(
                    EditUserEvent(
                      userId: widget.user.userId,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      email: _emailController.text,
                      phoneNumber: _phoneController.text,
                      status: _selectedStatus,
                    ),
                  );
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User details updated successfully")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B46F9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    fontFamily: 'Inter'
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2B46F9)),
            ),
          ),
        ),
      ],
    );
  }
}