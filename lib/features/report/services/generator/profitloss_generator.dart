import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/calculations/profitloss.calc.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

/// Generator class for creating complete Profit & Loss Report
class ProfitLossGenerator {
  Future<ProfitAndLossReport> generateFullReport(
    ProfitAndLossReport report,
    String businessName,
    List<DocumentLineItem> docLineData,
  ) async {
    final startDate = report.fiscal_period['startDate']!;
    final endDate = report.fiscal_period['endDate']!;

    final calculator = ProfitLossCalculator(
      lineItems: docLineData,
      startDate: startDate,
      endDate: endDate,
    );

    final sections = [
      _buildRevenueSection(calculator),
      _buildCostOfGoodsSoldSection(calculator),
      _buildCostOfServicesSection(calculator),
      _buildExpensesSection(calculator),
      _buildIncomeTaxSection(calculator),
    ];

    return report.copyWith(
      generated_at: DateTime.now(),
      sections: sections,
      gross_profit: calculator.calculateGrossProfit(),
      operating_income: calculator.calculateOperatingIncome(),
      income_before_tax: calculator.calculateIncomeBeforeTax(),
      income_tax_expense: calculator.calculateCurrentTaxExpense(),
      net_income: calculator.calculateNetIncome(),
    );
  }

  ReportSection _buildRevenueSection(ProfitLossCalculator calc) {
    final operatingRevenueGroup = ReportGroup(
      group_title: 'Operating Revenue',
      line_items: [
        ReportLineItem(
          item_title: 'Product Revenue',
          amount: calc.calculateProductRevenue(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Service Revenue',
          amount: calc.calculateServiceRevenue(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Subscription Revenue',
          amount: calc.calculateSubscriptionRevenue(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Rental Revenue',
          amount: calc.calculateRentalRevenue(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Other Operating Revenue',
          amount: calc.calculateOtherOperatingRevenue(),
          isIncrease: true,
        ),
      ],
      subtotal: calc.calculateTotalOperatingRevenue(),
    );

    final deductionsGroup = ReportGroup(
      group_title: 'Deductions from Revenue',
      line_items: [
        ReportLineItem(
          item_title: 'Sales Returns',
          amount: calc.calculateSalesReturns(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Sales Discounts',
          amount: calc.calculateSalesDiscounts(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Sales Allowances',
          amount: calc.calculateSalesAllowances(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalDeductions(),
    );

    final otherIncomeGroup = ReportGroup(
      group_title: 'Other Income',
      line_items: [
        ReportLineItem(
          item_title: 'Interest Income',
          amount: calc.calculateInterestIncome(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Dividend Income',
          amount: calc.calculateDividendIncome(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Investment Gains',
          amount: calc.calculateInvestmentGains(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Insurance Claims',
          amount: calc.calculateInsuranceClaims(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Gain on Sale of Assets',
          amount: calc.calculateGainOnSaleOfAssets(),
          isIncrease: true,
        ),
        ReportLineItem(
          item_title: 'Other Income',
          amount: calc.calculateOtherIncome(),
          isIncrease: true,
        ),
      ],
      subtotal: calc.calculateTotalOtherIncome(),
    );

    return ReportSection(
      section_title: 'Revenue',
      groups: [operatingRevenueGroup, deductionsGroup, otherIncomeGroup],
      grand_total: calc.calculateTotalRevenue(),
    );
  }

  ReportSection _buildCostOfGoodsSoldSection(ProfitLossCalculator calc) {
    return ReportSection(
      section_title: 'Cost of Goods Sold',
      groups: [
        ReportGroup(
          group_title: 'Cost of Goods Sold',
          line_items: [
            ReportLineItem(
              item_title: 'Opening Inventory',
              amount: calc.calculateOpeningInventory(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Purchases',
              amount: calc.calculatePurchases(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Delivery Fees',
              amount: calc.calculateDeliveryFees(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Purchase Returns',
              amount: calc.calculatePurchaseReturns(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Purchase Discounts',
              amount: calc.calculatePurchaseDiscounts(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Closing Inventory',
              amount: calc.calculateClosingInventory(),
              isIncrease: true,
            ),
            ReportLineItem(
              item_title: 'Other Cost of Goods Sold',
              amount: calc.calculateOtherCostOfGoodsSold(),
              isIncrease: false,
            ),
          ],
          subtotal: calc.calculateTotalCostOfGoodsSold(),
        ),
      ],
      grand_total: calc.calculateTotalCostOfGoodsSold(),
    );
  }

  ReportSection _buildCostOfServicesSection(ProfitLossCalculator calc) {
    return ReportSection(
      section_title: 'Cost of Services',
      groups: [
        ReportGroup(
          group_title: 'Cost of Services',
          line_items: [
            ReportLineItem(
              item_title: 'Direct Labor Costs',
              amount: calc.calculateDirectLaborCosts(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Contractor Costs',
              amount: calc.calculateContractorCosts(),
              isIncrease: false,
            ),
            ReportLineItem(
              item_title: 'Other Cost of Services',
              amount: calc.calculateOtherCostOfServices(),
              isIncrease: false,
            ),
          ],
          subtotal: calc.calculateTotalCostOfServices(),
        ),
      ],
      grand_total: calc.calculateTotalCostOfServices(),
    );
  }

  ReportSection _buildExpensesSection(ProfitLossCalculator calc) {
    final sellingMarketingGroup = ReportGroup(
      group_title: 'Selling & Marketing Expenses',
      line_items: [
        ReportLineItem(
          item_title: 'Advertising',
          amount: calc.calculateAdvertising(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Sales Commissions',
          amount: calc.calculateSalesCommissions(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Sales Salaries',
          amount: calc.calculateSalesSalaries(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Travel & Entertainment',
          amount: calc.calculateTravelAndEntertainment(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Shipping/Delivery-Out',
          amount: calc.calculateShippingDeliveryOut(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalSellingAndMarketing(),
    );

    final generalAdminGroup = ReportGroup(
      group_title: 'General & Administrative',
      line_items: [
        ReportLineItem(
          item_title: 'Office Salaries',
          amount: calc.calculateOfficeSalaries(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Office Rent',
          amount: calc.calculateOfficeRent(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Office Utilities',
          amount: calc.calculateOfficeUtilities(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Office Supplies',
          amount: calc.calculateOfficeSupplies(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Telephone & Internet',
          amount: calc.calculateTelephoneAndInternet(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Repairs & Maintenance',
          amount: calc.calculateRepairsAndMaintenance(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Insurance',
          amount: calc.calculateInsurance(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Professional Fees',
          amount: calc.calculateProfessionalFees(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Bank Charges',
          amount: calc.calculateBankCharges(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Training & Development',
          amount: calc.calculateTrainingAndDevelopment(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalGeneralAndAdministrative(),
    );

    final depreciationGroup = ReportGroup(
      group_title: 'Depreciation & Amortization',
      line_items: [
        ReportLineItem(
          item_title: 'Depreciation',
          amount: calc.calculateDepreciation(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Amortization',
          amount: calc.calculateAmortization(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalDepreciationAndAmortization(),
    );

    final otherExpensesGroup = ReportGroup(
      group_title: 'Other Expenses',
      line_items: [
        ReportLineItem(
          item_title: 'Licenses & Permits',
          amount: calc.calculateLicensesAndPermits(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Security',
          amount: calc.calculateSecurity(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Outsourcing Expenses',
          amount: calc.calculateOutsourcingExpenses(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Subscriptions & Tools',
          amount: calc.calculateSubscriptionsAndTools(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'HR & Recruiting',
          amount: calc.calculateHRAndRecruiting(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Interest Expense',
          amount: calc.calculateInterestExpense(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Loss on Sale of Assets',
          amount: calc.calculateLossOnSaleOfAssets(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Investment Losses',
          amount: calc.calculateInvestmentLosses(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Penalties & Fines',
          amount: calc.calculatePenaltiesAndFines(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Legal Settlements',
          amount: calc.calculateLegalSettlements(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Impairment Losses',
          amount: calc.calculateImpairmentLosses(),
          isIncrease: false,
        ),
        ReportLineItem(
          item_title: 'Other Expenses',
          amount: calc.calculateOtherExpenses(),
          isIncrease: false,
        ),
      ],
      subtotal: calc.calculateTotalOtherExpenses(),
    );

    return ReportSection(
      section_title: 'Expenses',
      groups: [
        sellingMarketingGroup,
        generalAdminGroup,
        depreciationGroup,
        otherExpensesGroup,
      ],
      grand_total: calc.calculateTotalOperatingExpenses(),
    );
  }

  ReportSection _buildIncomeTaxSection(ProfitLossCalculator calc) {
    return ReportSection(
      section_title: 'Income Tax Expense',
      groups: [
        ReportGroup(
          group_title: 'Income Tax',
          line_items: [
            ReportLineItem(
              item_title: 'Current Tax Expense',
              amount: calc.calculateCurrentTaxExpense(),
              isIncrease: false,
            ),
          ],
          subtotal: calc.calculateCurrentTaxExpense(),
        ),
      ],
      grand_total: calc.calculateCurrentTaxExpense(),
    );
  }
}
