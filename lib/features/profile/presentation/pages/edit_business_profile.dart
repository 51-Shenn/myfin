import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  final BusinessProfile? existingProfile;
  final String memberId;

  const EditBusinessProfileScreen({
    super.key,
    this.existingProfile,
    required this.memberId,
  });

  @override
  State<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  // Controllers
  late TextEditingController _companyNameController;
  late TextEditingController _regNoController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  // Image Picker
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;
    _companyNameController = TextEditingController(text: profile?.name ?? '');
    _regNoController = TextEditingController(
      text: profile?.registrationNo ?? '',
    );
    _emailController = TextEditingController(text: profile?.email ?? '');
    _contactController = TextEditingController(text: profile?.contactNo ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    // 1. Create updated object
    final updatedProfile = BusinessProfile(
      // If editing, keep ID. If new, use memberId or generate new UUID
      profileId: widget.existingProfile?.profileId ?? widget.memberId,
      name: _companyNameController.text,
      registrationNo: _regNoController.text,
      contactNo: _contactController.text,
      email: _emailController.text,
      address: _addressController.text,
      memberId: widget.memberId,
    );

    // 2. Call Bloc to save
    context.read<ProfileBloc>().add(UpdateBusinessProfileEvent(updatedProfile));

    // 3. Go back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Logo Section ---
            Center(
              child: GestureDetector(
                onTap: _showImageSourceModal,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.layers_outlined,
                                        size: 30,
                                        color: Color(0xFF2B46F9),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "COMPANY\nSLOGAN HERE",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2B46F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Details Header ---
            const Text(
              'COMPANY DETAILS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            // --- Fields ---
            _buildTextField(
              label: 'Company Name',
              hint: 'Company Inc.',
              controller: _companyNameController,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Registration Number',
              hint: '202301005921',
              controller: _regNoController,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Email Address',
              hint: 'company@gmail.com',
              controller: _emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Contact Number',
              hint: '+60 123456789',
              controller: _contactController,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Registered Address',
              hint: 'Level 23, Menara 1, KL Eco City...',
              controller: _addressController,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B46F9),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2B46F9),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
