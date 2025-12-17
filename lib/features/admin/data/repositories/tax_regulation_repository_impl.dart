import 'package:myfin/features/admin/data/datasources/tax_regulation_remote_data_source.dart';
import 'package:myfin/features/admin/data/models/tax_regulation_model.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
import 'package:myfin/features/admin/domain/repositories/tax_regulation_repository.dart';

class TaxRegulationRepositoryImpl implements TaxRegulationRepository {
  final TaxRegulationRemoteDataSource _remoteDataSource;

  TaxRegulationRepositoryImpl({
    required TaxRegulationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TaxRegulation>> getTaxRegulations() async {
    try {
      final models = await _remoteDataSource.getTaxRegulations();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get tax regulations: $e');
    }
  }

  @override
  Future<TaxRegulation> getTaxRegulationById(String id) async {
    try {
      final model = await _remoteDataSource.getTaxRegulationById(id);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get tax regulation: $e');
    }
  }

  @override
  Future<void> createTaxRegulation(TaxRegulation regulation) async {
    try {
      final model = TaxRegulationModel.fromEntity(regulation);
      await _remoteDataSource.createTaxRegulation(model);
    } catch (e) {
      throw Exception('Failed to create tax regulation: $e');
    }
  }

  @override
  Future<void> updateTaxRegulation(TaxRegulation regulation) async {
    try {
      final model = TaxRegulationModel.fromEntity(regulation);
      await _remoteDataSource.updateTaxRegulation(model);
    } catch (e) {
      throw Exception('Failed to update tax regulation: $e');
    }
  }

  @override
  Future<void> deleteTaxRegulation(String id) async {
    try {
      await _remoteDataSource.deleteTaxRegulation(id);
    } catch (e) {
      throw Exception('Failed to delete tax regulation: $e');
    }
  }
}
