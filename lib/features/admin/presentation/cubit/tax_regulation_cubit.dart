import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
import 'package:myfin/features/admin/domain/repositories/tax_regulation_repository.dart';
import 'package:myfin/features/admin/presentation/cubit/tax_regulation_state.dart';

class TaxRegulationCubit extends Cubit<TaxRegulationState> {
  final TaxRegulationRepository _repository;

  TaxRegulationCubit({required TaxRegulationRepository repository})
    : _repository = repository,
      super(TaxRegulationInitial());

  Future<void> loadTaxRegulations() async {
    emit(TaxRegulationLoading());
    try {
      final regulations = await _repository.getTaxRegulations();
      emit(TaxRegulationLoaded(regulations: regulations));
    } catch (e) {
      emit(TaxRegulationError(message: 'Failed to load tax regulations: $e'));
    }
  }

  Future<void> createTaxRegulation(
    TaxRegulation regulation,
    String adminId,
  ) async {
    try {
      final regulationWithAdmin = regulation.copyWith(
        createdBy: adminId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createTaxRegulation(regulationWithAdmin);
      emit(
        TaxRegulationOperationSuccess(
          message: 'Tax regulation created successfully',
        ),
      );
      await loadTaxRegulations();
    } catch (e) {
      emit(TaxRegulationError(message: 'Failed to create tax regulation: $e'));
    }
  }

  Future<void> updateTaxRegulation(TaxRegulation regulation) async {
    try {
      await _repository.updateTaxRegulation(regulation);
      emit(
        TaxRegulationOperationSuccess(
          message: 'Tax regulation updated successfully',
        ),
      );
      await loadTaxRegulations();
    } catch (e) {
      emit(TaxRegulationError(message: 'Failed to update tax regulation: $e'));
    }
  }

  Future<void> deleteTaxRegulation(String id, String adminId) async {
    try {
      final regulation = await _repository.getTaxRegulationById(id);
      final deletedRegulation = regulation.copyWith(
        deletedBy: adminId,
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.updateTaxRegulation(deletedRegulation);
      emit(
        TaxRegulationOperationSuccess(
          message: 'Tax regulation deleted successfully',
        ),
      );
      await loadTaxRegulations();
    } catch (e) {
      emit(TaxRegulationError(message: 'Failed to delete tax regulation: $e'));
    }
  }
}
