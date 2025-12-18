import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/balancesheet_calc.dart';
import 'package:myfin/features/report/services/calculations/profitloss_calc.dart';
import 'package:myfin/features/report/services/calculations/cashflow_calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Generator class for creating complete Balance Sheet
class BalanceSheetGenerator {
  Future<BalanceSheet> generateFullReport(
    BalanceSheet report,
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData, {
    double? netIncomeFromProfitLoss, // Accept net income from P&L
    double? endingCashFromCashFlow, // Accept ending cash from Cash Flow
  }) async {
    final asOfDate = report.fiscal_period['endDate']!;
    final startDate = report.fiscal_period['startDate']!;

    // Get net income from P&L calculator if not provided
    final netIncome =
        netIncomeFromProfitLoss ??
        ProfitLossCalculator(
          lineItems: docLineData,
          startDate: startDate,
          endDate: asOfDate,
        ).calculateNetIncome();

    // Get ending cash from Cash Flow calculator if not provided
    final endingCash =
        endingCashFromCashFlow ??
        CashFlowCalculator(
          lineItems: docLineData,
          startDate: startDate,
          endDate: asOfDate,
          netIncome: netIncome,
        ).calculateEndingCashBalance(0.0); // TODO: Get starting cash

    final calculator = BalanceSheetCalculator(
      lineItems: docLineData,
      asOfDate: asOfDate,
      cashBalance: endingCash, // Pass ending cash from Cash Flow
    );

    final sections = [
      _buildAssetsSection(calculator),
      _buildLiabilitiesSection(calculator),
      _buildEquitySection(calculator, netIncome),
    ];

    return report.copyWith(
      generated_at: DateTime.now(),
      sections: sections,
      total_assets: calculator.calculateTotalAssets(),
      total_liabilities: calculator.calculateTotalLiabilities(),
      total_equity: calculator.calculateTotalEquity(netIncome),
      total_liabilities_and_equity: calculator
          .calculateTotalLiabilitiesAndEquity(netIncome),
    );
  }

  ReportSection _buildAssetsSection(BalanceSheetCalculator calc) {
    final currentAssetsGroup = ReportGroup(
      group_title: 'Current Assets',
      line_items: [
        ReportLineItem(
          item_title: 'Cash & Cash Equivalents',
          amount: calc.calculateCashAndCashEquivalents(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Accounts Receivable',
          amount: calc.calculateAccountsReceivable(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Notes Receivable',
          amount: calc.calculateNotesReceivable(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Inventory',
          amount: calc.calculateInventory(),
          isIncrease: true,
        ),
      ],
      subtotal: calc.calculateTotalCurrentAssets(),
    );

    final nonCurrentAssetsGroup = ReportGroup(
      group_title: 'Non-Current Assets',
      line_items: [
        ReportLineItem(
          item_title: 'Property, Plant & Equipment (PP&E)',
          amount: calc.calculatePropertyPlantEquipment(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Accumulated Depreciation',
          amount: calc.calculateAccumulatedDepreciation(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Intangible Assets',
          amount: calc.calculateIntangibleAssets(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Long-term Investments',
          amount: calc.calculateLongTermInvestments(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Other Assets',
          amount: calc.calculateOtherAssets(),
          isIncrease: true,
        ),
      ],
      subtotal: calc.calculateTotalNonCurrentAssets(),
    );

    return ReportSection(
      section_title: 'Assets',
      groups: [currentAssetsGroup, nonCurrentAssetsGroup],
      grand_total: calc.calculateTotalAssets(),
    );
  }

  ReportSection _buildLiabilitiesSection(BalanceSheetCalculator calc) {
    final currentLiabilitiesGroup = ReportGroup(
      group_title: 'Current Liabilities',
      line_items: [
        ReportLineItem(
          item_title: 'Accounts Payable',
          amount: calc.calculateAccountsPayable(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Notes Payable',
          amount: calc.calculateNotesPayable(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Income Tax Payable',
          amount: calc.calculateIncomeTaxPayable(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Sales Taxes Payable',
          amount: calc.calculateSalesTaxesPayable(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Product Returns Liability',
          amount: calc.calculateProductReturnsLiability(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Other Current Liabilities',
          amount: calc.calculateOtherCurrentLiabilities(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalCurrentLiabilities(),
    );

    final longTermLiabilitiesGroup = ReportGroup(
      group_title: 'Long-term Liabilities',
      line_items: [
        ReportLineItem(
          item_title: 'Long-term Debt',
          amount: calc.calculateLongTermDebt(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Deferred Revenue (long-term)',
          amount: calc.calculateDeferredRevenueLongTerm(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Other Long-term Liabilities',
          amount: calc.calculateOtherLongTermLiabilities(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalLongTermLiabilities(),
    );

    return ReportSection(
      section_title: 'Liabilities',
      groups: [currentLiabilitiesGroup, longTermLiabilitiesGroup],
      grand_total: calc.calculateTotalLiabilities(),
    );
  }

  ReportSection _buildEquitySection(
    BalanceSheetCalculator calc,
    double netIncome,
  ) {
    // Using Corporate Equity as default
    final corporateEquityGroup = ReportGroup(
      group_title: 'Corporate Equity',
      line_items: [
        ReportLineItem(
          item_title: 'Shared Capital',
          amount: calc.calculateSharedCapital(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Shared Premium',
          amount: calc.calculateSharedPremium(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Retained Earnings',
          amount: calc.calculateRetainedEarnings(netIncome),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Others',
          amount: calc.calculateOtherCorporateEquity(),
          isIncrease: true,
        ),
      ],
      subtotal: calc.calculateTotalCorporateEquity(netIncome),
    );

    return ReportSection(
      section_title: 'Equity',
      groups: [corporateEquityGroup],
      grand_total: calc.calculateTotalEquity(netIncome),
    );
  }
}
