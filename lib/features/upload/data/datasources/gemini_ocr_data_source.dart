import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myfin/features/upload/presentation/widgets/doc_line_item_field.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';

class GeminiOCRDataSource {
  GeminiOCRDataSource();

  // API LOGIC

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

    if (keys.isEmpty) {
      throw Exception(
        "No API keys found in .env (Checked for GEMINI_API_KEY 1-4)",
      );
    }

    Object? lastError;

    // loop through Keys
    for (String apiKey in keys) {
      // loop through Models
      for (String modelName in _modelsToTry) {
        try {
          final keyId = apiKey.length > 4
              ? apiKey.substring(apiKey.length - 4)
              : "short-key";
          print("Attempting AI request | Key: ...$keyId | Model: $modelName");

          final model = GenerativeModel(model: modelName, apiKey: apiKey);
          final response = await model.generateContent(content);

          return response;
        } catch (e) {
          print("Failed ($modelName). Error: $e");
          lastError = e;
          continue;
        }
      }
    }

    throw Exception(
      "All AI models and 4 API keys failed. Last error: $lastError",
    );
  }

  // uses the 'lineCategory' list imported from doc_line_item_field.dart
  String _getFormattedCategories() {
    return lineCategory.map((e) => "- $e").join("\n");
  }

  // uses the 'docType' list imported from doc_details.dart
  String _getFormattedDocTypes() {
    return docType.map((e) => "- $e").join("\n");
  }

  // PROMPT GENERATION
  String _buildPrompt(String? userCompanyName) {
    final String categoryList = _getFormattedCategories();
    final String docTypeList = _getFormattedDocTypes();
    
    // logic instructions for the AI
    String contextLogic = "";
    if (userCompanyName != null && userCompanyName.isNotEmpty) {
      contextLogic = """
      MY COMPANY NAME: "$userCompanyName"

      CRITICAL CLASSIFICATION RULES:
      1. Look for the "Sender" (Who issued the document) and the "Receiver" (Bill To).
      2. IF the Sender is "MY COMPANY NAME" (or similar):
         - This is an OUTGOING document.
         - Type must be "Sales Invoice" or "Sales Order".
         - The other party is the "Customer".
      3. IF the Receiver is "MY COMPANY NAME" (or similar):
         - This is an INCOMING document.
         - Type must be "Supplier Invoice" or "Purchase Order".
         - The other party is the "Supplier".
      """;
    } else {
      contextLogic = "Classify based on standard accounting practices. Distinguish between Sales (Outgoing) and Supplier (Incoming/Expense) documents.";
    }

    return """
    You are an expert accountant. Analyze the provided file.
    
    $contextLogic
    
    STEP 1: EXTRACTION
    1. Extract document details:
       - "name": Format as "Entity Name - Number".
       - "type": Pick exact string from DOCUMENT TYPE LIST below.
       - "date": Date of issue (YYYY-MM-DD).
       - "due_date": The payment due date. If not explicitly stated, return null.
       - "total": Grand total amount.
    
    2. Extract Party Details (Metadata):
       - IF "Sales Invoice" or "Sales Order": Check for "Customer Name", "Customer Address", "Customer Contact".
       - IF "Supplier Invoice" or "Purchase Order": Check for "Supplier Name", "Supplier Address", "Supplier Contact".
       - **CRITICAL**: Only add these keys to the "metadata" list IF the information is explicitly visible in the document.
       - **DO NOT** include keys for missing information (e.g., if there is no Supplier Address on the receipt, do not include the "Supplier Address" key at all).

    3. Extract line items:
       - For "category", use the CATEGORY LIST below.

    DOCUMENT TYPE LIST:
    $docTypeList

    CATEGORY LIST:
    $categoryList

    Return strictly valid JSON:
    {
      "document": { 
        "name": "Entity Name - INV-001", 
        "type": "EXACT_TYPE_FROM_LIST", 
        "date": "YYYY-MM-DD", 
        "due_date": "YYYY-MM-DD",
        "total": 0.00 
      },
      "metadata": [
        { "key": "Supplier Name", "value": "Example Supplier" }
      ],
      "line_items": [
        { "description": "Item Name", "category": "EXACT_CATEGORY_FROM_LIST", "amount": 0.00 }
      ]
    }
    """;
  }

  Future<Map<String, dynamic>> extractDataFromMedia(
    String filePath,
    String mimeType,
    String? userCompanyName,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception("File does not exist");
    final bytes = await file.readAsBytes();

    final prompt = _buildPrompt(userCompanyName);

    try {
      final content = [
        Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
      ];

      return await _executeExtraction(content);
    } catch (e) {
      print("Media Extraction Error: $e");
      throw Exception("Extraction Failed: $e");
    }
  }

  // Excel converted to CSV string
  Future<Map<String, dynamic>> extractDataFromText(
    String textData,
    String? userCompanyName,
  ) async {
    final prompt = _buildPrompt(userCompanyName);
    final fullPrompt = "$prompt\n\nHERE IS THE DOCUMENT CONTENT:\n$textData";

    try {
      final content = [Content.text(fullPrompt)];
      return await _executeExtraction(content);
    } catch (e) {
      throw Exception("Text Extraction Failed: $e");
    }
  }

  Future<Map<String, dynamic>> extractDataFromImage(
    String imagePath,
    String? userCompanyName,
  ) async {
    return extractDataFromMedia(
      imagePath, 
      'image/jpeg', 
      userCompanyName,
    );
  }

  Future<Map<String, dynamic>> _executeExtraction(List<Content> content) async {
    final response = await _generateContentWithFallback(content);
    final responseText = response.text;

    if (responseText == null) throw Exception("No response from AI");

    String cleanJson = responseText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final dynamic decoded = jsonDecode(cleanJson);

    // FIX: Handle cases where AI returns a List instead of a Map
    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else if (decoded is List && decoded.isNotEmpty) {
      // If it's a list, return the first element if it's a map
      if (decoded.first is Map<String, dynamic>) {
        return decoded.first as Map<String, dynamic>;
      }
    }

    throw Exception("Invalid JSON format from AI. Expected Map, got: ${decoded.runtimeType}");
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