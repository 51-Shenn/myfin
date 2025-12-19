import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class BalanceSheetCalculator {
  final List<DocumentLineItem> lineItems;
  final DateTime asOfDate;
  final double cashBalance; 
  final TaxRegulation? salesTaxRegulation;
  final TaxRegulation? incomeTaxRegulation;

  BalanceSheetCalculator({
    required this.lineItems,
    required this.asOfDate,
    this.cashBalance = 0.0,
    this.salesTaxRegulation,
    this.incomeTaxRegulation,
  });

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

  double _sumCategory(String categoryCode, bool isIncrease) {
    final filteredItems = _filterByCategory(categoryCode);
    final sum = filteredItems.fold(0.0, (sum, item) => sum + item.total);
    return isIncrease ? sum : -sum;
  }

  double _calculateProgressiveTax(
    double taxableAmount,
    TaxRegulation? regulation,
  ) {
    if (regulation == null || regulation.rates.isEmpty) return 0.0;

    double totalTax = 0.0;

    for (final rate in regulation.rates) {
      final bracketMin = rate.minimumIncome;
      final bracketMax = rate.maximumIncome;

      if (taxableAmount <= bracketMin) {
        break;
      }

      final taxableInBracket = taxableAmount > bracketMax
          ? (bracketMax - bracketMin)
          : (taxableAmount - bracketMin);

      final taxInBracket = taxableInBracket * (rate.percentage / 100);
      totalTax += taxInBracket;

      if (taxableAmount <= bracketMax) {
        break;
      }
    }

    return totalTax;
  }

  double calculateCashAndCashEquivalents() => cashBalance;
  double calculateAccountsReceivable() =>
      _sumCategory('Accounts Receivable', true);
  double calculateNotesReceivable() => _sumCategory('Notes Receivable', true);
  double calculateInventory() => _sumCategory('Closing Inventory', true);

  double calculateTotalCurrentAssets() {
    return calculateCashAndCashEquivalents() +
        calculateAccountsReceivable() +
        calculateNotesReceivable() +
        calculateInventory();
  }

  double calculatePropertyPlantEquipment() =>
      _sumCategory('Purchase of Assets', true);

  double calculateAccumulatedDepreciation() {
    return _sumCategory('Purchase of Assets', true) *
        0.2; // Shown as positive in reports
  }

  double calculateIntangibleAssets() => _sumCategory('Intangible Assets', true);

  double calculateLongTermInvestments() =>
      _sumCategory('Long-term Investments', true);

  double calculateOtherAssets() => _sumCategory('Other Assets', true);

  double calculateTotalNonCurrentAssets() {
    return calculatePropertyPlantEquipment() -
        calculateAccumulatedDepreciation() +
        calculateIntangibleAssets() +
        calculateLongTermInvestments() +
        calculateOtherAssets();
  }

  double calculateTotalAssets() {
    return calculateTotalCurrentAssets() + calculateTotalNonCurrentAssets();
  }

  double calculateAccountsPayable() => _sumCategory('Accounts Payable', true);
  double calculateNotesPayable() => _sumCategory('Notes Payable', true);

  double calculateIncomeTaxPayable([double netIncome = 0.0]) {
    if (incomeTaxRegulation == null) {
      return _sumCategory('Tax Expense', true);
    }
    return _calculateProgressiveTax(netIncome, incomeTaxRegulation);
  }

  double calculateSalesTaxesPayable() {
    if (salesTaxRegulation == null) return 0.0;

    final productRevenue = _sumCategory('Product Revenue', true);
    final serviceRevenue = _sumCategory('Service Revenue', true);
    final totalRevenue = productRevenue + serviceRevenue;

    if (salesTaxRegulation!.rates.isNotEmpty) {
      final salesTaxRate = salesTaxRegulation!.rates.first.percentage;
      return totalRevenue * (salesTaxRate / 100);
    }

    return 0.0;
  }

  double calculateProductReturnsLiability() =>
      _sumCategory('Sales Returns', true);

  double calculateOtherCurrentLiabilities() => 0.0;

  double calculateTotalCurrentLiabilities([double netIncome = 0.0]) {
    return calculateAccountsPayable() +
        calculateNotesPayable() +
        calculateIncomeTaxPayable(netIncome) +
        calculateSalesTaxesPayable() +
        calculateProductReturnsLiability() +
        calculateOtherCurrentLiabilities();
  }

  double calculateLongTermDebt() => _sumCategory('Debt', true);

  double calculateDeferredRevenueLongTerm() => 0.0; // No specific category

  double calculateOtherLongTermLiabilities() => 0.0; // No specific category

  double calculateTotalLongTermLiabilities() {
    return calculateLongTermDebt() +
        calculateDeferredRevenueLongTerm() +
        calculateOtherLongTermLiabilities();
  }

  double calculateTotalLiabilities([double netIncome = 0.0]) {
    return calculateTotalCurrentLiabilities(netIncome) +
        calculateTotalLongTermLiabilities();
  }

  double calculateSharedCapital() => _sumCategory('Stock', true);

  double calculateSharedPremium() => _sumCategory('Shared Premium', true);

  double calculateRetainedEarnings(double netIncome) =>
      netIncome;

  double calculateOtherCorporateEquity() => 0.0;

  double calculateTotalCorporateEquity(double netIncome) {
    return calculateSharedCapital() +
        calculateSharedPremium() +
        calculateRetainedEarnings(netIncome) +
        calculateOtherCorporateEquity();
  }

  double calculateOwnersCapital() => _sumCategory('Owner Investment', true);

  double calculateOwnersDrawings() => _sumCategory('Owner Drawing', false);

  double calculateOtherOwnersEquity() => 0.0;

  double calculateTotalOwnersEquity(double netIncome) {
    return calculateOwnersCapital() -
        calculateOwnersDrawings() +
        netIncome +
        calculateOtherOwnersEquity();
  }

  double calculatePartnerCapital() => _sumCategory('Partner Investment', true);

  double calculatePartnerDrawings() =>
      _sumCategory('Partner Drawing', false); 

  double calculateTotalPartnershipEquity() {
    return calculatePartnerCapital() - calculatePartnerDrawings();
  }

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
    return calculateTotalLiabilities(netIncome) +
        calculateTotalEquity(netIncome, equityType: equityType);
  }

  bool verifyBalanceSheet(double netIncome, {String equityType = 'corporate'}) {
    final assets = calculateTotalAssets();
    final liabilitiesAndEquity = calculateTotalLiabilitiesAndEquity(
      netIncome,
      equityType: equityType,
    );
    return (assets - liabilitiesAndEquity).abs() < 0.01;
  }
}
