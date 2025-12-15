import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiOCRDataSource {
  late final GenerativeModel _model;

  GeminiOCRDataSource() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    // Using flash model for speed and cost-effectiveness for OCR tasks
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<Map<String, dynamic>> extractDataFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception("File does not exist");
    }

    final imageBytes = await file.readAsBytes();
    
    // Define the categories based on your Report Templates
    const categories = """
    - Sales Revenue
    - Service Revenue
    - Purchases
    - Office Salaries
    - Rent
    - Utilities
    - Office Supplies
    - Advertising
    - Travel & Entertainment
    - Repairs & Maintenance
    - Assets (Equipment/Furniture)
    - Miscellaneous
    """;

    final prompt = """
    Analyze this financial document (Receipt or Invoice). 
    Extract the following details and return them in strictly valid JSON format (no markdown code blocks).
    
    Structure:
    {
      "document": {
        "name": "Vendor Name + Invoice Number",
        "type": "Invoice or Receipt",
        "date": "YYYY-MM-DD", 
        "total": 100.00
      },
      "line_items": [
        {
          "description": "Item description",
          "category": "Select the closest category from the list below",
          "amount": 10.00
        }
      ],
      "metadata": [
        {"key": "Vendor Address", "value": "..."},
        {"key": "Tax Amount", "value": "..."}
      ]
    }

    Category List for line_items:
    $categories

    If the date is unclear, use today's date.
    Ensure 'amount' and 'total' are numbers (doubles).
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

      // Clean up markdown formatting if present (```json ... ```)
      String cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception("OCR Extraction Failed: $e");
    }
  }
}