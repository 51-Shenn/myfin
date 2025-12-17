import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
import 'package:myfin/features/admin/presentation/cubit/tax_regulation_cubit.dart';
import 'package:myfin/features/admin/presentation/cubit/tax_regulation_state.dart';
import 'package:myfin/features/admin/presentation/pages/edit_tax_regulation_screen.dart';
import 'package:myfin/features/admin/presentation/widgets/tax_regulation_card.dart';
import 'package:uuid/uuid.dart';

class TaxRegulationsListScreen extends StatefulWidget {
  const TaxRegulationsListScreen({super.key});

  @override
  State<TaxRegulationsListScreen> createState() =>
      _TaxRegulationsListScreenState();
}

class _TaxRegulationsListScreenState extends State<TaxRegulationsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaxRegulationCubit>().loadTaxRegulations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tax Regulations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<TaxRegulationCubit, TaxRegulationState>(
        listener: (context, state) {
          if (state is TaxRegulationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaxRegulationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaxRegulationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaxRegulationLoaded) {
            if (state.regulations.isEmpty) {
              return const Center(
                child: Text(
                  'No tax regulations found.\nTap + to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.regulations.length,
              itemBuilder: (context, index) {
                final regulation = state.regulations[index];
                return TaxRegulationCard(
                  id: regulation.id.substring(0, 6),
                  type: regulation.type,
                  name: regulation.name,
                  description: regulation.description,
                  isDeleted: regulation.deletedAt != null,
                  onTap: () => _navigateToEdit(context, regulation),
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        backgroundColor: const Color(0xFF2B46F9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    final newRegulation = TaxRegulation(
      id: const Uuid().v4(),
      name: '',
      type: '',
      description: '',
      rates: [],
      createdBy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: context.read<TaxRegulationCubit>(),
          child: EditTaxRegulationScreen(
            regulation: newRegulation,
            isNew: true,
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, TaxRegulation regulation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: context.read<TaxRegulationCubit>(),
          child: EditTaxRegulationScreen(regulation: regulation, isNew: false),
        ),
      ),
    );
  }
}
