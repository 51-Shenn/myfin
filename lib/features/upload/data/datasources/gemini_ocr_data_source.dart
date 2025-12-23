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
          print("[AI] Attempting Request | Key: ...$keyId | Model: $modelName");

          final model = GenerativeModel(model: modelName, apiKey: apiKey);
          final response = await model.generateContent(content);

          return response;
        } catch (e) {
          print("[AI] Failed ($modelName). Error: $e");
          lastError = e;
          continue;
        }
      }
    }

    throw Exception(
      "All AI models and 4 API keys failed. Last error: $lastError",
    );
  }

  String _getFormattedCategories() {
    return lineCategory.map((e) => "- $e").join("\n");
  }

  String _getFormattedDocTypes() {
    return docType.map((e) => "- $e").join("\n");
  }

  // PROMPT GENERATION
  String _buildPrompt(String? userCompanyName) {
    final String categoryList = _getFormattedCategories();
    final String docTypeList = _getFormattedDocTypes();
    
    String contextLogic = "";
    if (userCompanyName != null && userCompanyName.isNotEmpty) {
      contextLogic = """
      MY COMPANY NAME: "$userCompanyName"

      CRITICAL CLASSIFICATION RULES:
      1. Look for the "Sender" and "Receiver".
      2. IF Sender is "MY COMPANY NAME": It is "Sales Invoice".
      3. IF Receiver is "MY COMPANY NAME": It is "Supplier Invoice".
      """;
    } else {
      contextLogic = "Classify based on standard accounting practices.";
    }

    return """
    You are an expert accountant. Analyze the provided file content.
    
    $contextLogic
    
    STEP 1: EXTRACTION
    1. Extract document details:
       - "name": Format as "Entity Name - Number".
       - "type": Pick exact string from DOCUMENT TYPE LIST.
       - "date": YYYY-MM-DD.
       - "due_date": YYYY-MM-DD (or null).
       - "total": Grand total (numeric).
    
    2. Extract Party Details (Metadata):
       - Look for "Customer/Supplier Name", "Address", "Contact".
       - Only include keys if information exists.

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
        "type": "Sales Invoice", 
        "date": "2023-01-01", 
        "due_date": "2023-02-01",
        "total": 100.00 
      },
      "metadata": [
        { "key": "Supplier Name", "value": "Example Supplier" }
      ],
      "line_items": [
        { "description": "Item Name", "category": "Product Revenue", "amount": 50.00 }
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
      throw Exception("Media Extraction Failed: $e");
    }
  }

  Future<Map<String, dynamic>> extractDataFromText(
    String textData,
    String? userCompanyName,
  ) async {
    print("[AI] Sending Text Data to AI. Length: ${textData.length}");
    final prompt = _buildPrompt(userCompanyName);
    final fullPrompt = "$prompt\n\nHERE IS THE EXCEL/CSV CONTENT:\n$textData";

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

    print("[AI] Raw Response: $responseText"); // DEBUG LOG

    String cleanJson = responseText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final dynamic decoded = jsonDecode(cleanJson);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        if (decoded.first is Map<String, dynamic>) {
          return decoded.first as Map<String, dynamic>;
        }
      }
      throw Exception("JSON structure incorrect");
    } catch (e) {
      print("[AI] JSON Parse Error: $e");
      print("[AI] Bad JSON: $cleanJson");
      throw Exception("Failed to parse AI response: $e");
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
    Map these descriptions to categories:
    
    ALLOWED CATEGORIES:
    $categoryList
    
    DESCRIPTIONS:
    $itemsToCategorize

    Return strictly valid JSON { "Description": "Category" }:
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
      print("Categorization Error: $e");
      return {};
    }
  }
}