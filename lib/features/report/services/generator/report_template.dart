// template for sections and groups of reports

class ProfitAndLossTemplate {
  static const Map<String, dynamic> structure = {
    'Revenue': {
      'Operating Revenue': [
        'Sales Revenue',
        'Service Revenue',
        'Product Revenue',
        'Subscription Revenue',
        'Licensing Revenue',
        'Rental Income',
        'Consulting Income',
        'Maintenance Fees',
        'Freight/Delivery Revenue',
        'Royalties',
        'Franchise Fees',
        'Commission Income',
        'Contract Revenue',
      ],
      'Deductions from Revenue': [
        'Sales Returns',
        'Sales Discounts',
        'Sales Allowances',
        'Bad Debt Write-offs',
      ],
    },

    'Cost of Goods Sold': [
      'Opening Inventory',
      'Purchases',
      'Freight-In',
      'Direct Materials Used',
      'Direct Labor',
      'Manufacturing Overhead',
      'Factory Rent',
      'Factory Utilities',
      'Factory Depreciation',
      'Indirect Labor',
      'Indirect Materials',
      'Purchase Returns/Allowances',
      'Purchase Discounts',
      'Closing Inventory',
    ],

    'Cost of Services': [
      'Direct Labor Costs',
      'Contractor Costs',
      'Service Materials',
      'Subscriptions Required to Deliver Service',
      'Support Costs Allocated',
    ],

    'Operating Expenses': {
      'Selling & Marketing Expenses': [
        'Advertising',
        'Promotions',
        'Sales Commissions',
        'Sales Salaries',
        'Travel & Entertainment (Sales)',
        'Shipping/Delivery-Out',
        'Online Marketing',
        'Public Relations',
      ],
      'General & Administrative': [
        'Office Salaries',
        'Rent (Office)',
        'Utilities (Office)',
        'Office Supplies',
        'IT & Software Subscriptions',
        'Telephone & Internet',
        'Repairs & Maintenance',
        'Insurance (General, Property)',
        'Professional Fees (Legal, Accounting, Audit)',
        'Bank Charges',
        'Bad Debt Expense (Allowance Method)',
        'Training & Development',
      ],
      'Research & Development': [
        'Prototype Costs',
        'Development Salaries',
        'Lab Supplies',
        'Testing',
        'Patent Filing Costs',
        'Product Design Expenses',
      ],
      'Depreciation & Amortization': [
        'Depreciation (Office, Equipment, Vehicles)',
        'Amortization (Patents, Trademarks, Software)',
      ],
      'Other Operating Expenses': [
        'Licenses & Permits',
        'Security',
        'Outsourcing Expenses',
        'Subscriptions & Tools',
        'Recruiting & HR Costs',
      ],
    },

    'Other Income': [
      'Interest Income',
      'Dividend Income',
      'Gain on Sale of Equipment',
      'Unrealized Investment Gains',
      'Rent Income',
      'Foreign Exchange Gains',
      'Gain from Investment Fair Value Adjustments',
      'Insurance Compensation Received',
    ],

    'Other Expenses': [
      'Interest Expense',
      'Loss on Sale of Assets',
      'Foreign Exchange Losses',
      'Investment Fair Value Losses',
      'Penalties & Fines',
      'Litigation Settlements',
      'Restructuring Costs',
      'Impairment Losses',
    ],

    'Income Tax Expense': [
      'Current Tax Expense',
      'Deferred Tax Expense / Liability Adjustment',
    ],
  };
}

class CashFlowTemplate {
  static const Map<String, dynamic> structure = {
    'I. REVENUE': ['Sales Revenue', 'Service Revenue'],
  };
}

class BalanceSheetTemplate {
  static const Map<String, dynamic> structure = {
    'I. REVENUE': ['Sales Revenue', 'Service Revenue'],
  };
}

class AccountsPayableTemplate {
  static const Map<String, dynamic> structure = {
    'I. REVENUE': ['Sales Revenue', 'Service Revenue'],
  };
}

class AccountsReceivableTemplate {
  static const Map<String, dynamic> structure = {
    'I. REVENUE': ['Sales Revenue', 'Service Revenue'],
  };
}
