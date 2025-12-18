import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

/// Calculator class for Cash Flow Statement calculations
class CashFlowCalculator {
  final List<DocumentLineItem> lineItems;
  final DateTime startDate;
  final DateTime endDate;
  final double netIncome; // From Profit & Loss report

  CashFlowCalculator({
    required this.lineItems,
    required this.startDate,
    required this.endDate,
    required this.netIncome,
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

  /// Sum amounts for a specific category
  double _sumCategory(String categoryCode) {
    final filteredItems = _filterByCategory(categoryCode);
    return filteredItems.fold(0.0, (sum, item) => sum + item.total);
  }

  // Operating Activities
  double getNetIncome() => netIncome;

  double calculateDepreciationExpense() =>
      (_sumCategory('Purchase of Assets') * 0.2);

  double calculateAmortizationExpense() =>
      _sumCategory('Amortization (Patents, Trademarks, Software)');

  double calculateImpairmentLosses() => _sumCategory('Impairment Losses');

  double calculateLossOnSaleOfAssets() =>
      _sumCategory('Loss on Sale of Assets');

  double calculateGainOnSaleOfAssets() =>
      _sumCategory('Gain on Sale of Assets');

  double calculateUnrealizedGainsLosses() => 0.0; // TODO: Implement

  double calculateChangeInAccounts() => 0.0; // TODO: Implement

  double calculateTotalOperatingActivities() {
    return netIncome +
        calculateDepreciationExpense() +
        calculateAmortizationExpense() +
        calculateImpairmentLosses() +
        calculateLossOnSaleOfAssets() -
        calculateGainOnSaleOfAssets() +
        calculateUnrealizedGainsLosses() +
        calculateChangeInAccounts();
  }

  // Investing Activities
  double calculatePurchaseOfAssets() => _sumCategory('Purchase of Assets');

  double calculateProceedsFromSaleOfAssets() =>
      _sumCategory('Proceeds from Sale of Assets');

  double calculateMoneyLentToOthers() => 0.0; // TODO: Implement

  double calculateMoneyCollectedFromOthers() => 0.0; // TODO: Implement

  double calculateTotalInvestingActivities() {
    return -calculatePurchaseOfAssets() +
        calculateProceedsFromSaleOfAssets() -
        calculateMoneyLentToOthers() +
        calculateMoneyCollectedFromOthers();
  }

  // Financing Activities
  double calculateIssuanceOfStock() => 0.0; // TODO: Implement

  double calculateRepurchaseOfStock() => 0.0; // TODO: Implement

  double calculateDividendPayments() => 0.0; // TODO: Implement

  double calculateIssuanceOfLongTermDebt() => 0.0; // TODO: Implement

  double calculateRepaymentOfLongTermDebt() => 0.0; // TODO: Implement

  double calculateIssuanceOfShortTermNotes() => 0.0; // TODO: Implement

  double calculateRepaymentOfShortTermNotes() => 0.0; // TODO: Implement

  double calculateTotalFinancingActivities() {
    return calculateIssuanceOfStock() -
        calculateRepurchaseOfStock() -
        calculateDividendPayments() +
        calculateIssuanceOfLongTermDebt() -
        calculateRepaymentOfLongTermDebt() +
        calculateIssuanceOfShortTermNotes() -
        calculateRepaymentOfShortTermNotes();
  }

  // Net Increase/Decrease in Cash
  double calculateNetCashChange() {
    return calculateTotalOperatingActivities() +
        calculateTotalInvestingActivities() +
        calculateTotalFinancingActivities();
  }

  // Get starting cash balance (sum of Cash & Cash Equivalents before start date)
  double getStartingCashBalance() {
    final cashItems = lineItems.where((item) {
      // Only include Cash & Cash Equivalents category
      final isCashAccount = item.categoryCode == 'Cash & Cash Equivalents';

      // Only include items before the start date
      final itemDate = item.lineDate;
      if (itemDate == null) return false;

      return isCashAccount && itemDate.isBefore(startDate);
    }).toList();

    return cashItems.fold(0.0, (sum, item) => sum + item.total);
  }

  // Cash Balance (requires starting cash balance)
  double calculateEndingCashBalance(double startingCashBalance) {
    return startingCashBalance + calculateNetCashChange();
  }
}
