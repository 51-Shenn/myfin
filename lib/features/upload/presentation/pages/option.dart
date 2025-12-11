import 'package:flutter/material.dart';

enum Option {
  manual(
    title: 'Manual Entry',
    description: 'Type document information manually.',
    icon: Icons.keyboard,
    isMainOption: true,
    navigateTo: '/manual_entry',
  ),
  file(
    title: 'File Upload',
    description: 'Upload from device files\n(xlsx, pdf, png, jpg, etc.)',
    icon: Icons.insert_drive_file,
    isMainOption: true,
    navigateTo: '/',
  ),
  gallery(
    title: 'Select From',
    description: 'Gallery',
    icon: Icons.photo_library,
    isMainOption: false,
    navigateTo: '/',
  ),
  scan(
    title: 'Scan Using',
    description: 'Camera',
    icon: Icons.camera_alt,
    isMainOption: false,
    navigateTo: '/',
  );

  final String title;
  final String description;
  final IconData icon;
  final bool isMainOption;
  final String navigateTo;

  const Option({
    required this.title,
    required this.description,
    required this.icon,
    required this.isMainOption,
    required this.navigateTo,
  });
}