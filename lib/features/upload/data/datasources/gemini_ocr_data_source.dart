import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myfin/features/upload/presentation/widgets/doc_line_item_field.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';

class GeminiOCRDataSource {
  GeminiOCRDataSource();

  // --- API LOGIC ---

  List<String> _getApiKeys() {
    final envVarNames = [
      'GEMINI_API_KEY',
      'GEMINI_API_KEY_2',
      'GEMINI_API_KEY_3',
      'GEMINI_API_KEY_4',
    ];

    final List<String> validKeys = [];

    for (var name in envVarNames) {
      final key = dotenv.env[name];
      if (key != null && key.trim().isNotEmpty) {
        validKeys.add(key.trim());
      }
    }

    return validKeys;
  }

  final List<String> _modelsToTry = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-3-flash-preview',
  ];

  Future<GenerateContentResponse> _generateContentWithFallback(
    List<Content> content,
  ) async {
    final keys = _getApiKeys();

    if (keys.isEmpty)
      throw Exception(
        "No API keys found in .env (Checked for GEMINI_API_KEY 1-4)",
      );

    Object? lastError;

    // Loop through Keys
    for (String apiKey in keys) {
      // Loop through Models
      for (String modelName in _modelsToTry) {
        try {
          // Identify which key we are using (last 4 chars) for debugging
          final keyId = apiKey.length > 4
              ? apiKey.substring(apiKey.length - 4)
              : "short-key";
          print("Attempting AI request | Key: ...$keyId | Model: $modelName");

          final model = GenerativeModel(model: modelName, apiKey: apiKey);
          final response = await model.generateContent(content);

          return response; // Success! Return immediately.
        } catch (e) {
          print("Failed ($modelName). Error: $e");

          // Store error and continue to the next combination
          lastError = e;
          continue;
        }
      }
    }

    // If we reach here, 8 attempts (4 keys * 2 models) failed.
    throw Exception(
      "All AI models and 4 API keys failed. Last error: $lastError",
    );
  }

  // Uses the 'lineCategory' list imported from doc_line_item_field.dart
  String _getFormattedCategories() {
    return lineCategory.map((e) => "- $e").join("\n");
  }

  // Uses the 'docType' list imported from doc_details.dart
  String _getFormattedDocTypes() {
    return docType.map((e) => "- $e").join("\n");
  }

  Future<Map<String, dynamic>> extractDataFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) throw Exception("File does not exist");
    final imageBytes = await file.readAsBytes();

    // Dynamically build the prompts from the existing project lists
    final String categoryList = _getFormattedCategories();
    final String docTypeList = _getFormattedDocTypes();

    // --- UPDATED PROMPT ---
    final prompt = """
    You are an expert accountant. Analyze this image.
    
    1. Extract document details. 
       - For "name", construct a descriptive title using the format: "**Supplier Name** - **Invoice Number**".
         - Example: "Tenaga Nasional - INV-88291"
         - If no Invoice Number is found, use: "**Supplier Name** - **Date**".
       - For "type", you MUST pick the exact string from the DOCUMENT TYPE LIST below.
    
    2. Extract Key Entities to Metadata:
       - Extract the raw **Supplier Name** (Merchant Name).
       - Extract Contact Info: Address, Phone, and Email.
       
       - Add these to the "metadata" list. 
       - Keys MUST be exactly: 
         "Supplier Name", "Supplier Address", "Supplier Phone", "Supplier Email".
       
       - Do not include keys if the value is not visible on the document.

    3. Extract line items.
       - For "category", you MUST pick the exact string from the CATEGORY LIST below.
       - Do not invent new categories.

    DOCUMENT TYPE LIST:
    $docTypeList

    CATEGORY LIST:
    $categoryList

    Return strictly valid JSON:
    {
      "document": { 
        "name": "Supplier Name - INV-001", 
        "type": "EXACT_TYPE_FROM_LIST", 
        "date": "YYYY-MM-DD", 
        "total": 0.00 
      },
      "metadata": [
        { "key": "Supplier Name", "value": "Tenaga Nasional" },
        { "key": "Supplier Phone", "value": "+603-2222..." }
      ],
      "line_items": [
        { "description": "Item Name", "category": "EXACT_CATEGORY_FROM_LIST", "amount": 0.00 }
      ]
    }
    """;

    try {
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Calls the fallback logic
      final response = await _generateContentWithFallback(content);
      final responseText = response.text;

      if (responseText == null) throw Exception("No response from AI");

      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanJson);
    } catch (e) {
      print("Final Extraction Error: $e");
      throw Exception("OCR Extraction Failed after all retries: $e");
    }
  }

  Future<Map<String, String>> categorizeDescriptions(
    List<String> descriptions,
  ) async {
    if (descriptions.isEmpty) return {};

    final String categoryList = _getFormattedCategories();
    final String itemsToCategorize = descriptions.join(", ");

    final prompt =
        """
    You are an expert accountant. 
    Map the following transaction descriptions to the most appropriate category from the allowed list.
    
    ALLOWED CATEGORIES:
    $categoryList
    
    DESCRIPTIONS TO MAP:
    $itemsToCategorize

    If a description is vague, make your best guess based on standard accounting practices.
    If it is impossible to categorize, use "Other Expenses".

    Return strictly valid JSON format where key is the description and value is the category:
    {
      "Uber ride to airport": "Travel & Entertainment",
      "Dell Monitor": "Office Supplies"
    }
    """;

    try {
      final content = [Content.text(prompt)];

      // Calls the fallback logic
      final response = await _generateContentWithFallback(content);
      final responseText = response.text;

      if (responseText == null) return {};

      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      Map<String, dynamic> decoded = jsonDecode(cleanJson);

      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print("Final Categorization Error: $e");
      return {};
    }
  }
}
