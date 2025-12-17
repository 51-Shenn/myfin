// template for sections and groups of reports

class ProfitAndLossTemplate {
  static const Map<String, dynamic> structure = {
    'Revenue': {
      'Operating Revenue': [
        'Product Revenue',
        'Service Revenue',
        'Subscription Revenue',
        'Rental Revenue',
        'Other Operating Revenue',
      ],
      'Deductions from Revenue': [
        'Sales Returns',
        'Sales Discounts',
        'Sales Allowances',
      ],
      'Other Income': [
        'Interest Income',
        'Dividend Income',
        'Investment Gains',
        'Insurance Claims',
        'Gain on Sale of Assets',
        'Others',
      ],
    },

    'Cost of Goods Sold': [
      'Opening Inventory',
      'Purchases',
      'Delivery Fees',
      'Purchase Returns',
      'Purchase Discounts',
      'Closing Inventory',
      'Other Cost of Goods Sold',
    ],

    'Cost of Services': [
      'Direct Labor Costs',
      'Contractor Costs',
      'Other Cost of Services',
    ],

    'Expenses': {
      'Selling & Marketing Expenses': [
        'Advertising',
        'Sales Commissions',
        'Sales Salaries',
        'Travel & Entertainment',
        'Shipping/Delivery-Out',
      ],
      'General & Administrative': [
        'Office Salaries',
        'Office Rent',
        'Office Utilities',
        'Office Supplies',
        'Telephone & Internet',
        'Repairs & Maintenance',
        'Insurance',
        'Professional Fees',
        'Bank Charges',
        'Training & Development',
      ],
      'Depreciation & Amortization': [
        'Depreciation (Office, Equipment, Vehicles)',
        'Amortization (Patents, Trademarks, Software)',
      ],
      'Other Expenses': [
        'Licenses & Permits',
        'Security',
        'Outsourcing Expenses',
        'Subscriptions & Tools',
        'HR & Recruiting',
        'Interest Expense',
        'Loss on Sale of Assets',
        'Investment Losses',
        'Penalties & Fines',
        'Legal Settlements',
        'Impairment Losses',
        'Others',
      ],
    },

    'Income Tax Expense': ['Tax Expense'],
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
      'Unrealized Gains / Losses on Investments', // TODO: how calc
      'Change in Accounts',
    ],

    'Cash Flow from Investing Activities': [
      'Purchase of Assets', // new
      'Proceeds from Sale of Assets',
      'Money Lent to Others', // new
      'Money Collected from Others', // new
    ],

    'Cash Flow from Financing Activities': [
      'Issuance of Common Stock / Preferred Stock', // stock
      'Repurchase of Company Stock (Treasury Stock)', // stock repurchase
      'Payment of Dividends to Shareholders', // dividend payment
      'Issuance of Long-Term Debt', // debt
      'Repayment of Long-Term Debt Principal', // debt repayment
      'Issuance of Short-Term Notes Payable', // notes payable
      'Repayment of Short-Term Notes Payable', // notes repayment
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
        'Cash & Cash Equivalents', // new
        'Accounts Receivable',
        'Notes Receivable',
        'Inventory',
      ],

      'Non-Current Assets': [
        'Property, Plant & Equipment (PP&E)',
        'Accumulated Depreciation',
        'Intangible Assets', // new
        'Long-term Investments', // new
        'Other Assets', // new
      ],
    },

    'Liabilities': {
      'Current Liabilities': [
        'Accounts Payable',
        'Notes Payable',
        'Income Tax Payable',
        'Sales Taxes Payable',
        'Product Returns Liability',
        'Other Current Liabilities',
      ],

      'Long-term Liabilities': [
        'Long-term Debt',
        'Deferred Revenue (long-term)',
        'Other Long-term Liabilities',
      ],
    },

    'Equity': {
      'Corporate Equity': [
        'Shared Capital',
        'Shared Premium', // new
        'Retained Earnings',
        'Others',
      ],

      'Owner’s Equity': [
        'Owner’s Capital', // new
        'Owner’s Drawings', // new
        'Net Income',
        'Others',
      ],

      'Partnership Equity': [
        'Partner Capital Account', // new
        'Partner Drawings', // new
      ],
    },
  };
}

class AccountsReceivableTemplate {
  static const Map<String, dynamic> structure = {
    'Customer': ['Customer', 'Contact', 'Invoices'],
    'Invoices': [
      'Invoice Number',
      'Invoice Date',
      'Due Date',
      'Amount',
      'Status',
    ],
    'Total': ['Total Receivable', 'Total Overdue', 'Overdue Invoice Count'],
  };
}

class AccountsPayableTemplate {
  static const Map<String, dynamic> structure = {
    'Supplier': ['Supplier', 'Contact', 'Bills'],
    'Bills': ['Bill Number', 'Bill Date', 'Due Date', 'Amount', 'Status'],
    'Total': ['Total Payable', 'Total Overdue', 'Overdue Invoice Count'],
  };
}
