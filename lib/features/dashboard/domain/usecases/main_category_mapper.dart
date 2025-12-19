class MainCategoryMapper {
  // Income mapping: line item category -> main category
  static const Map<String, String> incomeMapping = {
    // Revenue
    'Product Revenue': 'Revenue',
    'Service Revenue': 'Revenue',
    'Subscription Revenue': 'Revenue',
    'Rental Revenue': 'Revenue',
    'Other Operating Revenue': 'Revenue',
    'Sales': 'Revenue',

    // Investment Income
    'Interest Income': 'Investment Income',
    'Dividend Income': 'Investment Income',
    'Investment Gains': 'Investment Income',

    // Other Income
    'Sales Returns': 'Other Income',
    'Sales Discounts': 'Other Income',
    'Sales Allowances': 'Other Income',
    'Insurance Claims': 'Other Income',
    'Gain on Sale of Assets': 'Other Income',
    'Other Income': 'Other Income',
    'Money Collected from Others': 'Other Income',
    'Owner Investment': 'Other Income',
    'Partner Investment': 'Other Income',
  };

  // Expense mapping: line item category -> main category
  static const Map<String, String> expenseMapping = {
    // Cost of Goods/Services
    'Opening Inventory': 'Cost of Goods/Services',
    'Purchases': 'Cost of Goods/Services',
    'Delivery Fees': 'Cost of Goods/Services',
    'Purchase Returns': 'Cost of Goods/Services',
    'Purchase Discounts': 'Cost of Goods/Services',
    'Closing Inventory': 'Cost of Goods/Services',
    'Other Cost of Goods Sold': 'Cost of Goods/Services',
    'Direct Labor Costs': 'Cost of Goods/Services',
    'Contractor Costs': 'Cost of Goods/Services',
    'Other Cost of Services': 'Cost of Goods/Services',

    // Operating Expenses
    'Office Salaries': 'Operating Expenses',
    'Office Rent': 'Operating Expenses',
    'Office Utilities': 'Operating Expenses',
    'Office Supplies': 'Operating Expenses',
    'Telephone & Internet': 'Operating Expenses',
    'Repairs & Maintenance': 'Operating Expenses',
    'Insurance': 'Operating Expenses',
    'Security': 'Operating Expenses',
    'Subscriptions & Tools': 'Operating Expenses',

    // Marketing & Sales
    'Advertising': 'Marketing & Sales',
    'Sales Commissions': 'Marketing & Sales',
    'Sales Salaries': 'Marketing & Sales',
    'Travel & Entertainment': 'Marketing & Sales',
    'Shipping/Delivery-Out': 'Marketing & Sales',

    // Financial Costs
    'Interest Expense': 'Financial Costs',
    'Bank Charges': 'Financial Costs',
    'Loss on Sale of Assets': 'Financial Costs',
    'Investment Losses': 'Financial Costs',

    // Administrative
    'Professional Fees': 'Administrative',
    'Training & Development': 'Administrative',
    'Licenses & Permits': 'Administrative',
    'HR & Recruiting': 'Administrative',
    'Legal Settlements': 'Administrative',
    'Outsourcing Expenses': 'Administrative',

    // Capital Expenditure
    'Purchase of Assets': 'Capital Expenditure',
    'Depreciation (Office, Equipment, Vehicles)': 'Capital Expenditure',
    'Amortization (Patents, Trademarks, Software)': 'Capital Expenditure',

    // Other Expenses
    'Penalties & Fines': 'Other Expenses',
    'Impairment Losses': 'Other Expenses',
    'Other Expenses': 'Other Expenses',
    'Money Lent to Others': 'Other Expenses',
    'Stock Repurchase': 'Other Expenses',
    'Dividend Payment': 'Other Expenses',
    'Debt Repayment': 'Other Expenses',
    'Notes Repayment': 'Other Expenses',
    'Owner Drawing': 'Other Expenses',
    'Partner Drawing': 'Other Expenses',
    'Tax Expense': 'Other Expenses',
  };

  /// Get main category for a line item category
  static String getMainCategory(String lineItemCategory, String type) {
    if (type == 'income') {
      return incomeMapping[lineItemCategory] ?? 'Other Income';
    }
    return expenseMapping[lineItemCategory] ?? 'Other Expenses';
  }

  /// Aggregate line items into main categories
  static Map<String, double> aggregateLineItems(
    List<dynamic> lineItems,
    String type,
    double Function(dynamic) getAmount,
  ) {
    final result = <String, double>{};

    for (var item in lineItems) {
      final amount = getAmount(item);
      if (amount > 0) {
        final categoryCode = (item as dynamic).categoryCode as String;
        final mainCat = getMainCategory(categoryCode, type);
        result[mainCat] = (result[mainCat] ?? 0) + amount;
      }
    }

    return result;
  }
}
