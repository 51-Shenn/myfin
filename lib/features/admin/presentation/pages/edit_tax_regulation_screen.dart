import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/domain/entities/tax_rate.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
import 'package:myfin/features/admin/presentation/cubit/tax_regulation_cubit.dart';
import 'package:myfin/features/admin/presentation/pages/edit_tax_rate_screen.dart';

class EditTaxRegulationScreen extends StatefulWidget {
  final TaxRegulation regulation;
  final bool isNew;

  const EditTaxRegulationScreen({
    super.key,
    required this.regulation,
    required this.isNew,
  });

  @override
  State<EditTaxRegulationScreen> createState() =>
      _EditTaxRegulationScreenState();
}

class _EditTaxRegulationScreenState extends State<EditTaxRegulationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TaxRegulation _currentRegulation;

  @override
  void initState() {
    super.initState();
    _currentRegulation = widget.regulation;
    _nameController = TextEditingController(text: widget.regulation.name);
    _typeController = TextEditingController(text: widget.regulation.type);
    _descriptionController = TextEditingController(
      text: widget.regulation.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.isNew ? 'Add Tax Regulation' : 'Edit Tax Regulation',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: _currentRegulation.deletedAt == null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tax Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _typeController,
              enabled: _currentRegulation.deletedAt == null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              enabled: _currentRegulation.deletedAt == null,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2B46F9)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tax Rate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _currentRegulation.deletedAt == null ? () => _navigateToTaxRate(context) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                  color: _currentRegulation.deletedAt != null ? Colors.grey[100] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentRegulation.rates.isEmpty
                          ? 'Add Tax Rates'
                          : '${_currentRegulation.rates.length} Rate(s) Configured',
                      style: TextStyle(
                        fontSize: 14,
                        color: _currentRegulation.deletedAt != null ? Colors.black38 : Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: _currentRegulation.deletedAt != null ? Colors.black38 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            if (_currentRegulation.deletedAt == null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B46F9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!widget.isNew) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _deleteRegulation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete Regulation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ]
          ],
        ),
      ),
    );
  }

  void _navigateToTaxRate(BuildContext context) async {
    final updatedRates = await Navigator.push<List<TaxRate>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTaxRateScreen(rates: _currentRegulation.rates),
      ),
    );

    if (updatedRates != null) {
      setState(() {
        _currentRegulation = _currentRegulation.copyWith(rates: updatedRates);
      });
    }
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tax Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_typeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tax Type is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentRegulation.rates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one tax rate is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedRegulation = _currentRegulation.copyWith(
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (widget.isNew) {
      context.read<TaxRegulationCubit>().createTaxRegulation(
        updatedRegulation,
        adminId,
      );
    } else {
      context.read<TaxRegulationCubit>().updateTaxRegulation(updatedRegulation);
    }

    Navigator.pop(context);
  }

  void _deleteRegulation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Tax Regulation'),
        content: const Text(
          'Are you sure you want to delete this tax regulation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<TaxRegulationCubit>().deleteTaxRegulation(
                _currentRegulation.id,
                adminId,
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
