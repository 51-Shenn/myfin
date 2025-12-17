import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';

abstract class TaxRegulationRepository {
  Future<List<TaxRegulation>> getTaxRegulations();

  Future<TaxRegulation> getTaxRegulationById(String id);

  Future<void> createTaxRegulation(TaxRegulation regulation);

  Future<void> updateTaxRegulation(TaxRegulation regulation);

  Future<void> deleteTaxRegulation(String id);
}
