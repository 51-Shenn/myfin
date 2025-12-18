import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/cashflow_calc.dart';
import 'package:myfin/features/report/services/calculations/profitloss_calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

/// Generator class for creating complete Cash Flow Statement
class CashFlowGenerator {
  Future<CashFlowStatement> generateFullReport(
    CashFlowStatement report,
    String businessName,
    List<Document> docData,
    List<DocumentLineItem> docLineData,
  ) async {
    final startDate = report.fiscal_period['startDate']!;
    final endDate = report.fiscal_period['endDate']!;

    // Calculate net income from P&L calculator
    final netIncome = ProfitLossCalculator(
      lineItems: docLineData,
      startDate: startDate,
      endDate: endDate,
    ).calculateNetIncome();

    final calculator = CashFlowCalculator(
      lineItems: docLineData,
      startDate: startDate,
      endDate: endDate,
      netIncome: netIncome,
    );

    final sections = [
      _buildOperatingActivitiesSection(calculator),
      _buildInvestingActivitiesSection(calculator),
      _buildFinancingActivitiesSection(calculator),
      _buildCashBalanceSection(calculator),
    ];

    return report.copyWith(
      generated_at: DateTime.now(),
      sections: sections,
      total_operating_cash_flow: calculator.calculateTotalOperatingActivities(),
      total_investing_cash_flow: calculator.calculateTotalInvestingActivities(),
      total_financing_cash_flow: calculator.calculateTotalFinancingActivities(),
      cash_balance: calculator.calculateNetCashChange(),
    );
  }

  ReportSection _buildOperatingActivitiesSection(CashFlowCalculator calc) {
    return ReportSection(
      section_title: 'Cash Flow from Operating Activities',
      groups: [
        ReportGroup(
          group_title: 'Operating Activities',
          line_items: [
            ReportLineItem(
              item_title: 'Net Income / Loss',
              amount: calc.getNetIncome(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Depreciation Expense',
              amount: calc.calculateDepreciationExpense(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Amortization Expense',
              amount: calc.calculateAmortizationExpense(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Impairment Losses',
              amount: calc.calculateImpairmentLosses(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Loss on Sale of Assets',
              amount: calc.calculateLossOnSaleOfAssets(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Gain on Sale of Assets',
              amount: calc.calculateGainOnSaleOfAssets(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Unrealized Gains / Losses on Investments',
              amount: calc.calculateUnrealizedGainsLosses(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Change in Accounts',
              amount: calc.calculateChangeInAccounts(),
              isIncrease: true,
            ),
          ],
          subtotal: calc.calculateTotalOperatingActivities(),
        ),
      ],
      grand_total: calc.calculateTotalOperatingActivities(),
    );
  }

  ReportSection _buildInvestingActivitiesSection(CashFlowCalculator calc) {
    return ReportSection(
      section_title: 'Cash Flow from Investing Activities',
      groups: [
        ReportGroup(
          group_title: 'Investing Activities',
          line_items: [
            ReportLineItem(
              item_title: 'Purchase of Assets',
              amount: calc.calculatePurchaseOfAssets(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Proceeds from Sale of Assets',
              amount: calc.calculateProceedsFromSaleOfAssets(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Money Lent to Others',
              amount: calc.calculateMoneyLentToOthers(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Money Collected from Others',
              amount: calc.calculateMoneyCollectedFromOthers(),
              isIncrease: true,
            ),
          ],
          subtotal: calc.calculateTotalInvestingActivities(),
        ),
      ],
      grand_total: calc.calculateTotalInvestingActivities(),
    );
  }

  ReportSection _buildFinancingActivitiesSection(CashFlowCalculator calc) {
    return ReportSection(
      section_title: 'Cash Flow from Financing Activities',
      groups: [
        ReportGroup(
          group_title: 'Financing Activities',
          line_items: [
            ReportLineItem(
              item_title: 'Issuance of Common Stock / Preferred Stock',
              amount: calc.calculateIssuanceOfStock(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Repurchase of Company Stock (Treasury Stock)',
              amount: calc.calculateRepurchaseOfStock(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Payment of Dividends to Shareholders',
              amount: calc.calculateDividendPayments(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Issuance of Long-Term Debt',
              amount: calc.calculateIssuanceOfLongTermDebt(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Repayment of Long-Term Debt Principal',
              amount: calc.calculateRepaymentOfLongTermDebt(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Issuance of Short-Term Notes Payable',
              amount: calc.calculateIssuanceOfShortTermNotes(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Repayment of Short-Term Notes Payable',
              amount: calc.calculateRepaymentOfShortTermNotes(),
              isIncrease: false,
            ),
          ],
          subtotal: calc.calculateTotalFinancingActivities(),
        ),
      ],
      grand_total: calc.calculateTotalFinancingActivities(),
    );
  }

  ReportSection _buildCashBalanceSection(CashFlowCalculator calc) {
    // Get starting cash balance from the calculator
    final startingCashBalance = calc.getStartingCashBalance();

    return ReportSection(
      section_title: 'Cash Balance',
      groups: [
        ReportGroup(
          group_title: 'Cash Balance',
          line_items: [
            ReportLineItem(
              item_title: 'Starting Cash Balance',
              amount: startingCashBalance,
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Net Increase / Decrease in Cash',
              amount: calc.calculateNetCashChange(),
              isIncrease: true,
            ),
          ],
          subtotal: calc.calculateEndingCashBalance(startingCashBalance),
        ),
      ],
      grand_total: calc.calculateEndingCashBalance(startingCashBalance),
    );
  }
}
