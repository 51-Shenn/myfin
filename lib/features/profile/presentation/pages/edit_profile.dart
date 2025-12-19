import 'dart:io';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;
  const EditProfileScreen({super.key, required this.arguments});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 1. Add Form Key
  final _formKey = GlobalKey<FormState>();

  late Member? member;
  late Uint8List? currentImageBytes;
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    member = widget.arguments['member'] as Member?;
    currentImageBytes = widget.arguments['imageBytes'] as Uint8List?;
    
    _firstNameController = TextEditingController(text: member?.first_name ?? '');
    _lastNameController = TextEditingController(text: member?.last_name ?? '');
    _emailController = TextEditingController(text: member?.email ?? '');
    _phoneController = TextEditingController(text: member?.phone_number ?? '');
    _addressController = TextEditingController(text: member?.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
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

  void _onSave() {
    if (member == null) return;

    // 2. Validate the form before saving
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }
    
    final updatedMember = Member(
      member_id: member!.member_id,
      username: member!.username,
      first_name: _firstNameController.text.trim(),
      last_name: _lastNameController.text.trim(),
      email: member!.email,
      phone_number: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      created_at: member!.created_at,
      status: member!.status,
    );

    context.read<ProfileBloc>().add(
      UpdateMemberProfileEvent(updatedMember, newImageFile: _selectedImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;
    if (_selectedImage != null) {
      backgroundImage = FileImage(_selectedImage!);
    } else if (currentImageBytes != null) {
      backgroundImage = MemoryImage(currentImageBytes!);
    } else {
      backgroundImage = const NetworkImage(
        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
      );
    }

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!state.isLoading && state.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
          // 3. Wrap content in Form
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          image: DecorationImage(
                            image: backgroundImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceModal,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B46F9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Fields ---
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First Name',
                        controller: _firstNameController,
                        // 4. Add specific validators
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  readOnly: true, 
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Address',
                  controller: _addressController,
                  inputType: TextInputType.multiline,
                  maxLines: 4,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Address is required' : null,
                ),

                const SizedBox(height: 40),

                // --- Save Button ---
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B46F9),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Updated Helper Method: Changed TextField to TextFormField and added validator
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator, // Added parameter
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
        TextFormField( // Changed from TextField to TextFormField
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          maxLines: maxLines,
          validator: validator, // Hooked up validation
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
          decoration: InputDecoration(
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
            // Added error border styling
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          ),
        ),
      ],
    );
  }
}