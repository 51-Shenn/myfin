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
      'Cash Flow from Operating Activities': [
        'Net Income / Loss', // get from profit & loss report
        'Depreciation Expense',
        'Amortization Expense',
        'Impairment Losses',
        'Loss on Sale of Assets',
        'Gain on Sale of Assets',
        'Deferred Tax Expense / Benefit',
        'Equity in Earnings of Unconsolidated Affiliates',
        'Stock-Based Compensation Expense',
        'Amortization of Bond Discount / Premium',
        'Unrealized Gains / Losses on Investments',
        'Change in Accounts Receivable',
        'Change in Inventory',
        'Change in Prepaid Expenses',
        'Change in Interest Receivable',
        'Change in Accounts Payable',
        'Change in Accrued Expenses',
        'Change in Unearned Revenue / Deferred Revenue',
        'Change in Income Tax Payable',
      ],

      'Cash Flow from Investing Activities': [
        'Purchase of Property, Plant, and Equipment (PP&E)',
        'Proceeds from Sale of PP&E',
        'Purchase of Intangible Assets',
        'Proceeds from Sale of Intangible Assets',
        'Purchase of Investment Securities',
        'Proceeds from Sale / Maturity of Investment Securities',
        'Lending Money to Other Entities (Notes Receivable)',
        'Collection / Repayment of Loans Made to Others',
      ],

      'Cash Flow from Financing Activities': [
        'Issuance of Common Stock or Preferred Stock',
        'Repurchase of Company Stock (Treasury Stock)',
        'Payment of Dividends to Shareholders',
        'Issuance of Long-Term Debt (Bonds, Notes, Mortgages)',
        'Repayment of Long-Term Debt Principal',
        'Issuance of Short-Term Notes Payable',
        'Repayment of Short-Term Notes Payable',
        'Payment of Financing Lease Obligations',
        'Proceeds from Exercising Stock Options',
      ],

      'Cash Balance': [
        'Add: Starting Cash Balance',
        'Net Increase / Decrease in Cash',
        'Equals: Ending Cash Balance',
      ],
    };
}

class BalanceSheetTemplate {
  static const Map<String, dynamic> structure = {
    'Assets': {
      'Current Assets': [
        'Cash & Cash Equivalents',
        'Accounts Receivable',
        'Inventory',
        'Supplies',
      ],

      'Non-Current Assets': {
        'Property, Plant & Equipment (PP&E)': [
          'Land',
          'Buildings',
          'Machinery & Equipment',
          'Furniture & Fixtures',
          'Vehicles',
          'Less: Accumulated Depreciation',
          'Construction In Progress',
        ],

        'Intangible Assets': [
          'Patents',
          'Trademarks',
          'Copyright',
          'Goodwill',
          'Software & Technology',
          'Licenses & Permits',
          'Franchise Rights',
        ],

        'Long-term Investments': [
          'Equity Investments',
          'Debt Investments',
          'Investment Property',
          'Notes Receivable',
        ],
      },

      'Other Assets': [
          'Deferred Tax Assets',
          'Security Deposits',
          'Life Insurance Cash Value',
          'Miscellaneous Assets',
        ],
    },

    'Liabilities': {
      'Current Liabilities': [
        'Accounts Payable',
        'Notes Payable (short-term)',
        'Current Portion of Long-term Debt',
        'Accrued Liabilities',
        'Accrued Salaries & Wages',
        'Accrued Interest Payable',
        'Accrued Taxes',
        'Accrued Utilities',
        'Unearned Revenue',
        'Customer Deposits',
        'Dividends Payable',
        'Income Tax Payable',
        'Sales/Payroll Taxes Payable',
        'Warranty Obligations (current)',
        'Product Returns Liability',
        'Other Current Liabilities',
      ],

      'Long-term Liabilities': [
        'Long-term Debt',
        'Bonds Payable',
        'Mortgage Payable',
        'Deferred Tax Liabilities',
        'Pension Obligations',
        'Long-term Lease Obligations',
        'Asset Retirement Obligations',
        'Long-term Warranty Obligations',
        'Contingent Liabilities',
        'Deferred Revenue (long-term)',
        'Long-term Deferred Compensation',
      ],
    },

    'Equity': {
      'Corporate Equity': [
        'Shared Capital',
        'Shared Premium',
        'Retained Earnings', // net income - dividends
        'Accumulated other comprehensive income (AOCI)',
        'Others',
      ],

      'Owner’s Equity': [
        'Owner’s Capital',
        'Owner’s Drawings',
        'Current Year Net Income',
        'Others',
      ],

      'Partnership Equity': [
        'Partner Capital Account',
        'Partner Drawings',
      ],
    },
  };
}

class AccountsReceivableTemplate {
  static const Map<String, dynamic> structure = {
    'Customer':[
      'Customer',
      'Contact',
      'Invoices',
    ],
    'Invoices': [
      'Invoice Number',
      'Invoice Date',
      'Due Date',
      'Amount',
      'Status',
    ],
    'Total': [
      'Total Receivable',
      'Total Overdue',
      'Overdue Invoice Count',
    ]
  };
}

class AccountsPayableTemplate {
  static const Map<String, dynamic> structure = {
    'Supplier':[
      'Supplier',
      'Contact',
      'Bills',
    ],
    'Bills': [
      'Bill Number',
      'Bill Date',
      'Due Date',
      'Amount',
      'Status',
    ],
    'Total': [
      'Total Payable',
      'Total Overdue',
      'Overdue Invoice Count',
    ]
  };
}