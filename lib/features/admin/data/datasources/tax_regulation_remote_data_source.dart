import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/admin/data/models/tax_regulation_model.dart';

class TaxRegulationRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'tax_regulations';

  TaxRegulationRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<List<TaxRegulationModel>> getTaxRegulations() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TaxRegulationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tax regulations: $e');
    }
  }

  Future<TaxRegulationModel> getTaxRegulationById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        throw Exception('Tax regulation not found');
      }

      return TaxRegulationModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch tax regulation: $e');
    }
  }

  Future<void> createTaxRegulation(TaxRegulationModel model) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(model.id)
          .set(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to create tax regulation: $e');
    }
  }

  Future<void> updateTaxRegulation(TaxRegulationModel model) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(model.id)
          .update(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to update tax regulation: $e');
    }
  }

  Future<void> deleteTaxRegulation(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete tax regulation: $e');
    }
  }

  /// Get the most recent tax regulation by type
  /// Returns null if no regulation of the specified type exists
  Future<TaxRegulationModel?> getTaxRegulationByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: type)
          .where('deletedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return TaxRegulationModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch tax regulation by type: $e');
    }
  }
}
