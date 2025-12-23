import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class CashFlowCalculator {
  final List<DocumentLineItem> lineItems;
  final DateTime startDate;
  final DateTime endDate;
  final double netIncome;

  CashFlowCalculator({
    required this.lineItems,
    required this.startDate,
    required this.endDate,
    required this.netIncome,
  });

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

  double _sumCategory(String categoryCode) {
    final filteredItems = _filterByCategory(categoryCode);
    return filteredItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double getNetIncome() => netIncome;

  double calculateDepreciationExpense() =>
      -(_sumCategory('Purchase of Assets') * 0.2);

  double calculateAmortizationExpense() =>
      -_sumCategory('Amortization (Patents, Trademarks, Software)');

  double calculateImpairmentLosses() => -_sumCategory('Impairment Losses');

  double calculateLossOnSaleOfAssets() =>
      -_sumCategory('Loss on Sale of Assets');

  double calculateGainOnSaleOfAssets() =>
      _sumCategory('Gain on Sale of Assets');

  double calculateUnrealizedGainsLosses() {
    return _sumCategory('Investment Gains') - _sumCategory('Investment Losses');
  }

  double calculateChangeInAccounts() {
    final openingInventory = _sumCategory('Opening Inventory');
    final closingInventory = _sumCategory('Closing Inventory');
    final inventoryChange = closingInventory - openingInventory;
    return -inventoryChange;
  }

  double calculateTotalOperatingActivities() {
    return netIncome +
        calculateDepreciationExpense() +
        calculateAmortizationExpense() +
        calculateImpairmentLosses() +
        calculateLossOnSaleOfAssets() +
        calculateGainOnSaleOfAssets() +
        calculateUnrealizedGainsLosses() +
        calculateChangeInAccounts();
  }

  double calculatePurchaseOfAssets() => -_sumCategory('Purchase of Assets');

  double calculateProceedsFromSaleOfAssets() =>
      _sumCategory('Proceeds from Sale of Assets');

  double calculateMoneyLentToOthers() => -_sumCategory('Money Lent to Others');

  double calculateMoneyCollectedFromOthers() =>
      _sumCategory('Money Collected from Others');

  double calculateTotalInvestingActivities() {
    return calculatePurchaseOfAssets() +
        calculateProceedsFromSaleOfAssets() +
        calculateMoneyLentToOthers() +
        calculateMoneyCollectedFromOthers();
  }

  double calculateIssuanceOfStock() => _sumCategory('Stock');

  double calculateRepurchaseOfStock() => _sumCategory('Stock Repurchase');

  double calculateDividendPayments() => -_sumCategory('Dividend Payment');

  double calculateIssuanceOfLongTermDebt() => -_sumCategory('Debt');

  double calculateRepaymentOfLongTermDebt() => -_sumCategory('Debt Repayment');

  double calculateIssuanceOfShortTermNotes() => -_sumCategory('Notes Payable');

  double calculateRepaymentOfShortTermNotes() =>
      -_sumCategory('Notes Repayment');

  double calculateTotalFinancingActivities() {
    return calculateIssuanceOfStock() +
        calculateRepurchaseOfStock() +
        calculateDividendPayments() +
        calculateIssuanceOfLongTermDebt() +
        calculateRepaymentOfLongTermDebt() +
        calculateIssuanceOfShortTermNotes() +
        calculateRepaymentOfShortTermNotes();
  }

  double calculateNetCashChange() {
    return calculateTotalOperatingActivities() +
        calculateTotalInvestingActivities() +
        calculateTotalFinancingActivities();
  }

  double getStartingCashBalance() {
    final cashItems = lineItems.where((item) {
      final isCashAccount = item.categoryCode == 'Cash & Cash Equivalents';

      final itemDate = item.lineDate;
      if (itemDate == null) return false;

      return isCashAccount && itemDate.isBefore(startDate);
    }).toList();

    return cashItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double calculateEndingCashBalance(double startingCashBalance) {
    return startingCashBalance + calculateNetCashChange();
  }
}
