import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiOCRDataSource {
  late final GenerativeModel _model;

  GeminiOCRDataSource() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    // Using flash model is sufficient for text extraction and is faster/cheaper
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<Map<String, dynamic>> extractDataFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception("File does not exist");
    }

    final imageBytes = await file.readAsBytes();
    
    // --- YOUR SPECIFIC ACCOUNTING HIERARCHY ---
    const accountingStructure = """
    PROFIT & LOSS - REVENUE:
    - Sales Revenue
    - Service Revenue
    - Product Revenue
    - Subscription Revenue (SaaS)
    - Licensing Revenue
    - Rental Income
    - Consulting Income
    - Maintenance Fees
    - Freight/Delivery Revenue
    - Royalties
    - Franchise Fees
    - Commission Income
    - Contract Revenue
    - Sales Returns
    - Sales Discounts
    - Sales Allowances
    - Bad Debt Write-offs

    PROFIT & LOSS - COST OF GOODS SOLD (COGS):
    - Purchases
    - Freight-In
    - Direct Materials Used
    - Direct Labor
    - Manufacturing Overhead
    - Factory Rent
    - Factory Utilities
    - Depreciation (Factory)
    - Indirect Labor
    - Indirect Materials
    - Purchase Returns/Allowances
    - Purchase Discounts

    PROFIT & LOSS - OPERATING EXPENSES:
    - Advertising
    - Promotions
    - Sales Commissions
    - Sales Salaries
    - Travel & Entertainment (Sales)
    - Shipping/Delivery-Out
    - Online Marketing
    - Public Relations
    - Office Salaries
    - Rent (Office)
    - Utilities (Office)
    - Office Supplies
    - IT & Software Subscriptions
    - Telephone & Internet
    - Repairs & Maintenance
    - Insurance (General, Property)
    - Professional Fees (Legal, Accounting, Audit)
    - Bank Charges
    - Bad Debt Expense
    - Training & Development
    - Prototype Costs
    - Development Salaries
    - Lab Supplies
    - Testing
    - Patent Filing Costs
    - Product Design Expenses
    - Depreciation (Office, Equipment, Vehicles)
    - Amortization
    - Licenses & Permits
    - Security
    - Outsourcing Expenses
    - Subscriptions & Tools
    - Recruiting & HR Costs

    PROFIT & LOSS - OTHER INCOME/EXPENSES:
    - Interest Income
    - Dividend Income
    - Gain on Sale of Equipment
    - Interest Expense
    - Loss on Sale of Assets
    - Foreign Exchange Losses
    - Penalties & Fines

    BALANCE SHEET - ASSETS:
    - Cash & Cash Equivalents
    - Accounts Receivable
    - Inventory
    - Supplies
    - Land
    - Buildings
    - Machinery & Equipment
    - Furniture & Fixtures
    - Vehicles
    - Software & Technology
    - Deferred Tax Assets
    - Security Deposits

    BALANCE SHEET - LIABILITIES:
    - Accounts Payable
    - Notes Payable
    - Accrued Liabilities
    - Accrued Salaries & Wages
    - Unearned Revenue
    - Customer Deposits
    - Income Tax Payable
    - Long-term Debt
    - Deferred Tax Liabilities
    """;

    final prompt = """
    You are an expert accountant. Analyze this image (Receipt, Invoice, or Bill). 
    
    1. Extract the document metadata (Vendor, Date, Total).
    2. Extract every line item.
    3. **CRITICAL STEP**: For every line item, categorize it by selecting the *exact string* from the 'Accounting Hierarchy' list below that best matches the item. 
       - If it is a purchase of physical goods for resale, use 'Purchases' (COGS).
       - If it is a meal or taxi, use 'Travel & Entertainment'.
       - If it is a computer for the office, use 'Office Supplies' (if small) or 'Machinery & Equipment' (if asset).
       - If it is a bill for internet, use 'Telephone & Internet'.
    
    Accounting Hierarchy:
    $accountingStructure

    Return the result in strictly valid JSON format (no markdown).
    
    JSON Structure:
    {
      "document": {
        "name": "Vendor Name",
        "type": "Invoice or Receipt",
        "date": "YYYY-MM-DD", 
        "total": 0.00
      },
      "line_items": [
        {
          "description": "Item description found on paper",
          "category": "EXACT_NAME_FROM_HIERARCHY", 
          "amount": 0.00
        }
      ],
      "metadata": [
        {"key": "Vendor Address", "value": "..."}
      ]
    }

    Rules:
    - If date is missing, use today's date.
    - Ensure 'amount' is a number (double).
    - Do not invent new categories. You MUST use one from the list provided.
    """;

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception("No response from AI");
      }

      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      return jsonDecode(cleanJson);
    } catch (e) {
      print("Gemini Error: $e");
      throw Exception("OCR Extraction Failed: $e");
    }
  }
}