import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

/// Calculator class for Profit & Loss calculations
class ProfitLossCalculator {
  final List<DocumentLineItem> lineItems;
  final DateTime startDate;
  final DateTime endDate;

  ProfitLossCalculator({
    required this.lineItems,
    required this.startDate,
    required this.endDate,
  });

  /// Filter line items by category code and date range
  List<DocumentLineItem> _filterByCategory(String categoryCode) {
    return lineItems.where((item) {
      final itemDate = item.lineDate ?? item.lineDate;
      if (itemDate == null) return false;

      final isInDateRange =
          itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          itemDate.isBefore(endDate.add(const Duration(days: 1)));
      return item.categoryCode == categoryCode && isInDateRange;
    }).toList();
  }

  /// Sum amounts for a specific category using debit/credit logic
  double _sumCategory(String categoryCode, {bool useDebit = true}) {
    return _filterByCategory(
      categoryCode,
    ).fold(0.0, (sum, item) => sum + (useDebit ? item.debit : item.credit));
  }

  double _sumCategoryByTotal(String categoryCode) {
    return _filterByCategory(
      categoryCode,
    ).fold(0.0, (sum, item) => sum + item.total);
  }

  // revenue
  double calculateProductRevenue() =>
      _sumCategory('Product Revenue', useDebit: false);
  double calculateServiceRevenue() =>
      _sumCategory('Service Revenue', useDebit: false);
  double calculateSubscriptionRevenue() =>
      _sumCategory('Subscription Revenue', useDebit: false);
  double calculateRentalRevenue() =>
      _sumCategory('Rental Revenue', useDebit: false);
  double calculateOtherOperatingRevenue() =>
      _sumCategory('Other Operating Revenue', useDebit: false);

  double calculateSalesReturns() => _sumCategory('Sales Returns');
  double calculateSalesDiscounts() => _sumCategory('Sales Discounts');
  double calculateSalesAllowances() => _sumCategory('Sales Allowances');

  double calculateInterestIncome() =>
      _sumCategory('Interest Income', useDebit: false);
  double calculateDividendIncome() =>
      _sumCategory('Dividend Income', useDebit: false);
  double calculateInvestmentGains() =>
      _sumCategory('Investment Gains', useDebit: false);
  double calculateInsuranceClaims() =>
      _sumCategory('Insurance Claims', useDebit: false);
  double calculateGainOnSaleOfAssets() =>
      _sumCategory('Gain on Sale of Assets', useDebit: false);
  double calculateOtherIncome() =>
      _sumCategory('Other Income', useDebit: false);

  // cogs
  double calculateOpeningInventory() => _sumCategory('Opening Inventory');
  double calculatePurchases() => _sumCategory('Purchases');
  double calculateDeliveryFees() => _sumCategory('Delivery Fees');
  double calculatePurchaseReturns() =>
      _sumCategory('Purchase Returns', useDebit: false);
  double calculatePurchaseDiscounts() =>
      _sumCategory('Purchase Discounts', useDebit: false);
  double calculateClosingInventory() =>
      _sumCategory('Closing Inventory', useDebit: false);
  double calculateOtherCostOfGoodsSold() =>
      _sumCategory('Other Cost of Goods Sold');

  // cos
  double calculateDirectLaborCosts() => _sumCategory('Direct Labor Costs');
  double calculateContractorCosts() => _sumCategory('Contractor Costs');
  double calculateOtherCostOfServices() =>
      _sumCategory('Other Cost of Services');

  // expense
  double calculateAdvertising() => _sumCategory('Advertising');
  double calculateSalesCommissions() => _sumCategory('Sales Commissions');
  double calculateSalesSalaries() => _sumCategory('Sales Salaries');
  double calculateTravelAndEntertainment() =>
      _sumCategory('Travel & Entertainment');
  double calculateShippingDeliveryOut() =>
      _sumCategory('Shipping/Delivery-Out');

  double calculateOfficeSalaries() => _sumCategory('Office Salaries');
  double calculateOfficeRent() => _sumCategory('Office Rent');
  double calculateOfficeUtilities() => _sumCategory('Office Utilities');
  double calculateOfficeSupplies() => _sumCategory('Office Supplies');
  double calculateTelephoneAndInternet() =>
      _sumCategory('Telephone & Internet');
  double calculateRepairsAndMaintenance() =>
      _sumCategory('Repairs & Maintenance');
  double calculateInsurance() => _sumCategory('Insurance');
  double calculateProfessionalFees() => _sumCategory('Professional Fees');
  double calculateBankCharges() => _sumCategory('Bank Charges');
  double calculateTrainingAndDevelopment() =>
      _sumCategory('Training & Development');

  double calculateDepreciation() =>
      (_sumCategoryByTotal('Purchase of Assets') * 0.2);
  double calculateAmortization() =>
      _sumCategory('Amortization (Patents, Trademarks, Software)');

  double calculateLicensesAndPermits() => _sumCategory('Licenses & Permits');
  double calculateSecurity() => _sumCategory('Security');
  double calculateOutsourcingExpenses() => _sumCategory('Outsourcing Expenses');
  double calculateSubscriptionsAndTools() =>
      _sumCategory('Subscriptions & Tools');
  double calculateHRAndRecruiting() => _sumCategory('HR & Recruiting');
  double calculateInterestExpense() => _sumCategory('Interest Expense');
  double calculateLossOnSaleOfAssets() =>
      _sumCategory('Loss on Sale of Assets');
  double calculateInvestmentLosses() => _sumCategory('Investment Losses');
  double calculatePenaltiesAndFines() => _sumCategory('Penalties & Fines');
  double calculateLegalSettlements() => _sumCategory('Legal Settlements');
  double calculateImpairmentLosses() => _sumCategory('Impairment Losses');
  double calculateOtherExpenses() => _sumCategory('Other Expenses');

  double calculateCurrentTaxExpense() => _sumCategory('Tax Expense');

  // totals
  double calculateTotalOperatingRevenue() {
    return calculateProductRevenue() +
        calculateServiceRevenue() +
        calculateSubscriptionRevenue() +
        calculateRentalRevenue() +
        calculateOtherOperatingRevenue();
  }

  double calculateTotalDeductions() {
    return calculateSalesReturns() +
        calculateSalesDiscounts() +
        calculateSalesAllowances();
  }

  double calculateNetOperatingRevenue() {
    return calculateTotalOperatingRevenue() - calculateTotalDeductions();
  }

  double calculateTotalOtherIncome() {
    return calculateInterestIncome() +
        calculateDividendIncome() +
        calculateInvestmentGains() +
        calculateInsuranceClaims() +
        calculateGainOnSaleOfAssets() +
        calculateOtherIncome();
  }

  double calculateTotalRevenue() {
    return calculateNetOperatingRevenue() + calculateTotalOtherIncome();
  }

  double calculateTotalCostOfGoodsSold() {
    return calculateOpeningInventory() +
        calculatePurchases() +
        calculateDeliveryFees() -
        calculatePurchaseReturns() -
        calculatePurchaseDiscounts() -
        calculateClosingInventory() +
        calculateOtherCostOfGoodsSold();
  }

  double calculateTotalCostOfServices() {
    return calculateDirectLaborCosts() +
        calculateContractorCosts() +
        calculateOtherCostOfServices();
  }

  double calculateGrossProfit() {
    return calculateTotalRevenue() -
        calculateTotalCostOfGoodsSold() -
        calculateTotalCostOfServices();
  }

  double calculateTotalSellingAndMarketing() {
    return calculateAdvertising() +
        calculateSalesCommissions() +
        calculateSalesSalaries() +
        calculateTravelAndEntertainment() +
        calculateShippingDeliveryOut();
  }

  double calculateTotalGeneralAndAdministrative() {
    return calculateOfficeSalaries() +
        calculateOfficeRent() +
        calculateOfficeUtilities() +
        calculateOfficeSupplies() +
        calculateTelephoneAndInternet() +
        calculateRepairsAndMaintenance() +
        calculateInsurance() +
        calculateProfessionalFees() +
        calculateBankCharges() +
        calculateTrainingAndDevelopment();
  }

  double calculateTotalDepreciationAndAmortization() {
    return calculateDepreciation() + calculateAmortization();
  }

  double calculateTotalOtherExpenses() {
    return calculateLicensesAndPermits() +
        calculateSecurity() +
        calculateOutsourcingExpenses() +
        calculateSubscriptionsAndTools() +
        calculateHRAndRecruiting() +
        calculateInterestExpense() +
        calculateLossOnSaleOfAssets() +
        calculateInvestmentLosses() +
        calculatePenaltiesAndFines() +
        calculateLegalSettlements() +
        calculateImpairmentLosses() +
        calculateOtherExpenses();
  }

  double calculateTotalOperatingExpenses() {
    return calculateTotalSellingAndMarketing() +
        calculateTotalGeneralAndAdministrative() +
        calculateTotalDepreciationAndAmortization() +
        calculateTotalOtherExpenses();
  }

  double calculateOperatingIncome() {
    return calculateGrossProfit() - calculateTotalOperatingExpenses();
  }

  double calculateIncomeBeforeTax() {
    return calculateOperatingIncome();
  }

  double calculateNetIncome() {
    return calculateIncomeBeforeTax() - calculateCurrentTaxExpense();
  }
}
