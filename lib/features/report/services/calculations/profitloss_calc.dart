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

  /// Sum amounts for a specific category using total field
  /// - isIncrease=true: Returns positive sum (revenue, income - increases profit)
  /// - isIncrease=false: Returns negative sum (expenses, costs - decreases profit)
  double _sumCategory(String categoryCode, bool isIncrease) {
    final filteredItems = _filterByCategory(categoryCode);
    final sum = filteredItems.fold(0.0, (sum, item) => sum + item.total);
    // Use isIncrease to determine if this adds to or subtracts from profit
    return isIncrease ? sum : -sum;
  }

  // Revenue categories (isIncrease: true)
  double calculateProductRevenue() => _sumCategory('Product Revenue', true);
  double calculateServiceRevenue() => _sumCategory('Service Revenue', true);
  double calculateSubscriptionRevenue() =>
      _sumCategory('Subscription Revenue', true);
  double calculateRentalRevenue() => _sumCategory('Rental Revenue', true);
  double calculateOtherOperatingRevenue() =>
      _sumCategory('Other Operating Revenue', true);

  // Deductions from revenue (isIncrease: false - these reduce revenue)
  double calculateSalesReturns() => _sumCategory('Sales Returns', false);
  double calculateSalesDiscounts() => _sumCategory('Sales Discounts', false);
  double calculateSalesAllowances() => _sumCategory('Sales Allowances', false);

  // Other income (isIncrease: true)
  double calculateInterestIncome() => _sumCategory('Interest Income', true);
  double calculateDividendIncome() => _sumCategory('Dividend Income', true);
  double calculateInvestmentGains() => _sumCategory('Investment Gains', true);
  double calculateInsuranceClaims() => _sumCategory('Insurance Claims', true);
  double calculateGainOnSaleOfAssets() =>
      _sumCategory('Gain on Sale of Assets', true);
  double calculateOtherIncome() => _sumCategory('Other Income', true);

  // Cost of Goods Sold (isIncrease: false for costs, true for reductions)
  double calculateOpeningInventory() =>
      _sumCategory('Opening Inventory', false);
  double calculatePurchases() => _sumCategory('Purchases', false);
  double calculateDeliveryFees() => _sumCategory('Delivery Fees', false);
  double calculatePurchaseReturns() =>
      _sumCategory('Purchase Returns', true); // Reduces COGS
  double calculatePurchaseDiscounts() =>
      _sumCategory('Purchase Discounts', true); // Reduces COGS
  double calculateClosingInventory() =>
      _sumCategory('Closing Inventory', true); // Reduces COGS
  double calculateOtherCostOfGoodsSold() =>
      _sumCategory('Other Cost of Goods Sold', false);

  // Cost of Services (isIncrease: false - all are expenses)
  double calculateDirectLaborCosts() =>
      _sumCategory('Direct Labor Costs', false);
  double calculateContractorCosts() => _sumCategory('Contractor Costs', false);
  double calculateOtherCostOfServices() =>
      _sumCategory('Other Cost of Services', false);

  // Operating Expenses (isIncrease: false - all reduce profit)
  double calculateAdvertising() => _sumCategory('Advertising', false);
  double calculateSalesCommissions() =>
      _sumCategory('Sales Commissions', false);
  double calculateSalesSalaries() => _sumCategory('Sales Salaries', false);
  double calculateTravelAndEntertainment() =>
      _sumCategory('Travel & Entertainment', false);
  double calculateShippingDeliveryOut() =>
      _sumCategory('Shipping/Delivery-Out', false);

  double calculateOfficeSalaries() => _sumCategory('Office Salaries', false);
  double calculateOfficeRent() => _sumCategory('Office Rent', false);
  double calculateOfficeUtilities() => _sumCategory('Office Utilities', false);
  double calculateOfficeSupplies() => _sumCategory('Office Supplies', false);
  double calculateTelephoneAndInternet() =>
      _sumCategory('Telephone & Internet', false);
  double calculateRepairsAndMaintenance() =>
      _sumCategory('Repairs & Maintenance', false);
  double calculateInsurance() => _sumCategory('Insurance', false);
  double calculateProfessionalFees() =>
      _sumCategory('Professional Fees', false);
  double calculateBankCharges() => _sumCategory('Bank Charges', false);
  double calculateTrainingAndDevelopment() =>
      _sumCategory('Training & Development', false);

  double calculateDepreciation() =>
      (_sumCategory('Purchase of Assets', false) * 0.2);
  double calculateAmortization() =>
      _sumCategory('Amortization (Patents, Trademarks, Software)', false);

  double calculateLicensesAndPermits() =>
      _sumCategory('Licenses & Permits', false);
  double calculateSecurity() => _sumCategory('Security', false);
  double calculateOutsourcingExpenses() =>
      _sumCategory('Outsourcing Expenses', false);
  double calculateSubscriptionsAndTools() =>
      _sumCategory('Subscriptions & Tools', false);
  double calculateHRAndRecruiting() => _sumCategory('HR & Recruiting', false);
  double calculateInterestExpense() => _sumCategory('Interest Expense', false);
  double calculateLossOnSaleOfAssets() =>
      _sumCategory('Loss on Sale of Assets', false);
  double calculateInvestmentLosses() =>
      _sumCategory('Investment Losses', false);
  double calculatePenaltiesAndFines() =>
      _sumCategory('Penalties & Fines', false);
  double calculateLegalSettlements() =>
      _sumCategory('Legal Settlements', false);
  double calculateImpairmentLosses() =>
      _sumCategory('Impairment Losses', false);
  double calculateOtherExpenses() => _sumCategory('Other Expenses', false);

  double calculateCurrentTaxExpense() => _sumCategory('Tax Expense', false);

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
    return calculateTotalOperatingRevenue() + calculateTotalDeductions();
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
        calculateDeliveryFees() +
        calculatePurchaseReturns() +
        calculatePurchaseDiscounts() +
        calculateClosingInventory() +
        calculateOtherCostOfGoodsSold();
  }

  double calculateTotalCostOfServices() {
    return calculateDirectLaborCosts() +
        calculateContractorCosts() +
        calculateOtherCostOfServices();
  }

  double calculateGrossProfit() {
    return calculateTotalRevenue() +
        calculateTotalCostOfGoodsSold() +
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
    return calculateGrossProfit() + calculateTotalOperatingExpenses();
  }

  /// Income Before Tax = Operating Income + Other Income (non-operating)
  double calculateIncomeBeforeTax() {
    return calculateOperatingIncome();
  }

  double calculateNetIncome() {
    return calculateIncomeBeforeTax() + calculateCurrentTaxExpense();
  }
}
