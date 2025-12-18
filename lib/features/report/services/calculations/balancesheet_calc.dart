import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

/// Calculator class for Balance Sheet calculations
class BalanceSheetCalculator {
  final List<DocumentLineItem> lineItems;
  final DateTime asOfDate;
  final double cashBalance; // Ending cash from Cash Flow Statement

  BalanceSheetCalculator({
    required this.lineItems,
    required this.asOfDate,
    this.cashBalance = 0.0,
  });

  /// Filter line items by category code up to the date
  List<DocumentLineItem> _filterByCategory(String categoryCode) {
    return lineItems.where((item) {
      final itemDate = item.lineDate ?? item.lineDate;
      if (itemDate == null) return false;

      final isBeforeOrOnDate = itemDate.isBefore(
        asOfDate.add(const Duration(days: 1)),
      );
      return item.categoryCode == categoryCode && isBeforeOrOnDate;
    }).toList();
  }

  /// Sum debits for asset accounts (debit increases assets)
  double _sumDebits(String categoryCode) {
    final filteredItems = _filterByCategory(categoryCode);
    return filteredItems.fold(0.0, (sum, item) => sum + item.debit);
  }

  /// Sum credits for asset accounts (credit decreases assets)
  double _sumCredits(String categoryCode) {
    final filteredItems = _filterByCategory(categoryCode);
    return filteredItems.fold(0.0, (sum, item) => sum + item.credit);
  }

  /// For assets: Debit - Credit = Net Asset Value
  double _netAssetValue(String categoryCode) {
    return _sumDebits(categoryCode) - _sumCredits(categoryCode);
  }

  /// For liabilities/equity: Credit - Debit = Net Liability/Equity Value
  double _netLiabilityValue(String categoryCode) {
    return _sumCredits(categoryCode) - _sumDebits(categoryCode);
  }

  // ASSETS - Current Assets (use debit - credit)
  /// Cash & Cash Equivalents comes from Cash Flow Statement ending balance
  double calculateCashAndCashEquivalents() => cashBalance;
  double calculateAccountsReceivable() => _netAssetValue('Accounts Receivable');
  double calculateNotesReceivable() => _netAssetValue('Notes Receivable');
  double calculateInventory() => _netAssetValue('Closing Inventory');

  double calculateTotalCurrentAssets() {
    return calculateCashAndCashEquivalents() +
        calculateAccountsReceivable() +
        calculateNotesReceivable() +
        calculateInventory();
  }

  // ASSETS - Non-Current Assets (use debit - credit)
  double calculatePropertyPlantEquipment() =>
      _netAssetValue('Purchase of Assets');

  /// Accumulated depreciation is a contra-asset (credit account that reduces assets)
  /// Store it separately as accumulated on the credit side of the asset account
  double calculateAccumulatedDepreciation() {
    // This should be tracked separately, but for now calculate as 20% of PPE
    return _netAssetValue('Purchase of Assets') *
        0.2; // Shown as positive in reports
  }

  double calculateIntangibleAssets() => 0.0; // TODO: Implement
  double calculateLongTermInvestments() => 0.0; // TODO: Implement
  double calculateOtherAssets() => 0.0; // TODO: Implement

  double calculateTotalNonCurrentAssets() {
    return calculatePropertyPlantEquipment() -
        calculateAccumulatedDepreciation() + // Subtract because it's contra-asset
        calculateIntangibleAssets() +
        calculateLongTermInvestments() +
        calculateOtherAssets();
  }

  double calculateTotalAssets() {
    return calculateTotalCurrentAssets() + calculateTotalNonCurrentAssets();
  }

  // LIABILITIES - Current Liabilities (use credit - debit)
  double calculateAccountsPayable() => _netLiabilityValue('Accounts Payable');
  double calculateNotesPayable() => _netLiabilityValue('Notes Payable');
  double calculateIncomeTaxPayable() => _netLiabilityValue('Tax Expense');
  double calculateSalesTaxesPayable() => 0.0; // TODO: Implement
  double calculateProductReturnsLiability() =>
      _netLiabilityValue('Sales Returns');
  double calculateOtherCurrentLiabilities() => 0.0; // TODO: Implement

  double calculateTotalCurrentLiabilities() {
    return calculateAccountsPayable() +
        calculateNotesPayable() +
        calculateIncomeTaxPayable() +
        calculateSalesTaxesPayable() +
        calculateProductReturnsLiability() +
        calculateOtherCurrentLiabilities();
  }

  // LIABILITIES - Long-term Liabilities
  double calculateLongTermDebt() => 0.0; // TODO: Implement
  double calculateDeferredRevenueLongTerm() => 0.0; // TODO: Implement
  double calculateOtherLongTermLiabilities() => 0.0; // TODO: Implement

  double calculateTotalLongTermLiabilities() {
    return calculateLongTermDebt() +
        calculateDeferredRevenueLongTerm() +
        calculateOtherLongTermLiabilities();
  }

  double calculateTotalLiabilities() {
    return calculateTotalCurrentLiabilities() +
        calculateTotalLongTermLiabilities();
  }

  // EQUITY - Corporate Equity (use credit - debit)
  double calculateSharedCapital() =>
      0.0; // TODO: Implement with actual capital accounts
  double calculateSharedPremium() => 0.0; // TODO: Implement
  double calculateRetainedEarnings(double netIncome) =>
      netIncome; // Simplified - should accumulate over time
  double calculateOtherCorporateEquity() => 0.0; // TODO: Implement

  double calculateTotalCorporateEquity(double netIncome) {
    return calculateSharedCapital() +
        calculateSharedPremium() +
        calculateRetainedEarnings(netIncome) +
        calculateOtherCorporateEquity();
  }

  // EQUITY - Owner's Equity
  double calculateOwnersCapital() => 0.0; // TODO: Implement
  double calculateOwnersDrawings() => 0.0; // TODO: Implement
  double calculateOtherOwnersEquity() => 0.0; // TODO: Implement

  double calculateTotalOwnersEquity(double netIncome) {
    return calculateOwnersCapital() -
        calculateOwnersDrawings() + // Subtract drawings
        netIncome +
        calculateOtherOwnersEquity();
  }

  // EQUITY - Partnership Equity (use credit - debit)
  double calculatePartnerCapital() => 0.0; // TODO: Implement
  double calculatePartnerDrawings() =>
      0.0; // TODO: Implement (debit balance, reduces equity)

  double calculateTotalPartnershipEquity() {
    return calculatePartnerCapital() - calculatePartnerDrawings();
  }

  // Total Equity (use whichever equity type is applicable)
  double calculateTotalEquity(
    double netIncome, {
    String equityType = 'corporate',
  }) {
    switch (equityType) {
      case 'corporate':
        return calculateTotalCorporateEquity(netIncome);
      case 'owner':
        return calculateTotalOwnersEquity(netIncome);
      case 'partnership':
        return calculateTotalPartnershipEquity();
      default:
        return calculateTotalCorporateEquity(netIncome);
    }
  }

  double calculateTotalLiabilitiesAndEquity(
    double netIncome, {
    String equityType = 'corporate',
  }) {
    return calculateTotalLiabilities() +
        calculateTotalEquity(netIncome, equityType: equityType);
  }

  /// Verify the accounting equation: Assets = Liabilities + Equity
  bool verifyBalanceSheet(double netIncome, {String equityType = 'corporate'}) {
    final assets = calculateTotalAssets();
    final liabilitiesAndEquity = calculateTotalLiabilitiesAndEquity(
      netIncome,
      equityType: equityType,
    );
    // Allow for small floating point differences
    return (assets - liabilitiesAndEquity).abs() < 0.01;
  }
}
