import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myfin/features/report/services/generator/report_template.dart';

class GeminiOCRDataSource {
  late final GenerativeModel _model;

  GeminiOCRDataSource() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
  }

  // 2. Helper function to flatten your nested Template Map into a String list
  String _getDynamicCategories() {
    final Set<String> categories = {};

    // Helper to recursively dig through the Map/List structure
    void extract(dynamic data) {
      if (data is Map) {
        for (var value in data.values) {
          extract(value);
        }
      } else if (data is List) {
        for (var item in data) {
          if (item is String) {
            categories.add(item);
          } else {
            extract(item);
          }
        }
      }
    }

    // Extract from P&L (Expenses/Revenue)
    extract(ProfitAndLossTemplate.structure);
    
    // Optional: Extract from Balance Sheet (Assets) if you want to track equipment purchases
    extract(BalanceSheetTemplate.structure['Assets']); 

    // Convert to a clean bulleted string
    return categories.map((e) => "- $e").join("\n");
  }

  Future<Map<String, dynamic>> extractDataFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) throw Exception("File does not exist");
    final imageBytes = await file.readAsBytes();
    
    // 3. Generate the list dynamically
    final String dynamicCategoryList = _getDynamicCategories();

    final prompt = """
    You are an expert accountant. Analyze this image.
    
    Extract data and categorize every line item using ONLY the list below. 
    You MUST pick the exact string from this list. Do not invent new categories.

    VALID CATEGORY LIST:
    $dynamicCategoryList

    Return strictly valid JSON:
    {
      "document": { "name": "Vendor", "type": "Invoice", "date": "YYYY-MM-DD", "total": 0.00 },
      "line_items": [
        { "description": "Item Name", "category": "EXACT_CATEGORY_FROM_LIST", "amount": 0.00 }
      ],
      "metadata": []
    }
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

      if (responseText == null) throw Exception("No response from AI");

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

  Future<Map<String, String>> categorizeDescriptions(List<String> descriptions) async {
    if (descriptions.isEmpty) return {};

    final String dynamicCategoryList = _getDynamicCategories();
    final String itemsToCategorize = descriptions.join(", ");

    final prompt = """
    You are an expert accountant. 
    Map the following transaction descriptions to the most appropriate category from the allowed list.
    
    ALLOWED CATEGORIES:
    $dynamicCategoryList
    
    DESCRIPTIONS TO MAP:
    $itemsToCategorize

    If a description is vague, make your best guess based on standard accounting practices.
    If it is impossible to categorize, use "Miscellaneous Expenses".

    Return strictly valid JSON format where key is the description and value is the category:
    {
      "Uber ride to airport": "Travel & Entertainment (Sales)",
      "Dell Monitor": "Office Supplies"
    }
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) return {};

      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      Map<String, dynamic> decoded = jsonDecode(cleanJson);
      
      // Ensure values are strings
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print("Gemini Categorization Error: $e");
      return {};
    }
  }
}