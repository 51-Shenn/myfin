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

    if (keys.isEmpty) {
      throw Exception(
        "No API keys found in .env (Checked for GEMINI_API_KEY 1-4)",
      );
    }

    Object? lastError;

    // Loop through Keys
    for (String apiKey in keys) {
      // Loop through Models
      for (String modelName in _modelsToTry) {
        try {
          final keyId = apiKey.length > 4
              ? apiKey.substring(apiKey.length - 4)
              : "short-key";
          print("Attempting AI request | Key: ...$keyId | Model: $modelName");

          final model = GenerativeModel(model: modelName, apiKey: apiKey);
          final response = await model.generateContent(content);

          return response; // Success! Return immediately.
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

  // Uses the 'lineCategory' list imported from doc_line_item_field.dart
  String _getFormattedCategories() {
    return lineCategory.map((e) => "- $e").join("\n");
  }

  // Uses the 'docType' list imported from doc_details.dart
  String _getFormattedDocTypes() {
    return docType.map((e) => "- $e").join("\n");
  }

  // --- PROMPT GENERATION (Reused for all file types) ---
  String _buildPrompt() {
    final String categoryList = _getFormattedCategories();
    final String docTypeList = _getFormattedDocTypes();

    return """
    You are an expert accountant. Analyze the provided file (Image, PDF, or Text Data).
    
    STEP 1: CLASSIFICATION
    Identify if this document is an **Invoice** (a request for payment issued TO a customer) or a **Bill/Receipt** (a document received FROM a supplier/merchant for an expense).
    
    STEP 2: EXTRACTION RULES
    1. Extract document details:
       - For "name", use format: "**Entity Name** - **Number**".
       - For "type", you MUST pick the exact string from the DOCUMENT TYPE LIST below.
    
    2. Extract Metadata based on Classification:
       - **IF THE DOCUMENT IS AN INVOICE (Accounts Receivable):** 
         Focus on the **Customer/Client** (the "Bill To" party). 
         Extract: "Customer Name", "Customer Address", "Customer Phone", "Customer Email".
       
       - **IF THE DOCUMENT IS A BILL or RECEIPT (Accounts Payable/Expense):** 
         Focus on the **Supplier/Merchant** (the "From" party). 
         Extract: "Supplier Name", "Supplier Address", "Supplier Phone", "Supplier Email".
       
       - Add these to the "metadata" list using the exact keys mentioned above.
       - Only include keys if the value is clearly visible.

    3. Extract line items:
       - For "category", you MUST pick the exact string from the CATEGORY LIST below.

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
        "total": 0.00 
      },
      "metadata": [
        { "key": "Supplier Name", "value": "Example Supplier" },
        { "key": "Supplier Address", "value": "123 Street, City" }
      ],
      "line_items": [
        { "description": "Item Name", "category": "EXACT_CATEGORY_FROM_LIST", "amount": 0.00 }
      ]
    }
    """;
  }


  // --- PUBLIC METHODS ---

  // 1. Handle Images (JPG, PNG) and PDFs (Binary data)
  Future<Map<String, dynamic>> extractDataFromMedia(
    String filePath,
    String mimeType,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception("File does not exist");
    final bytes = await file.readAsBytes();

    final prompt = _buildPrompt();

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

  // 2. Handle Text Data (Excel converted to CSV string)
  Future<Map<String, dynamic>> extractDataFromText(String textData) async {
    final prompt = _buildPrompt();
    final fullPrompt = "$prompt\n\nHERE IS THE DOCUMENT CONTENT:\n$textData";

    try {
      final content = [Content.text(fullPrompt)];
      return await _executeExtraction(content);
    } catch (e) {
      throw Exception("Text Extraction Failed: $e");
    }
  }

  // 3. Wrapper for Backward Compatibility (defaults to image/jpeg)
  Future<Map<String, dynamic>> extractDataFromImage(String imagePath) async {
    return extractDataFromMedia(imagePath, 'image/jpeg');
  }

  // --- PRIVATE HELPER ---
  Future<Map<String, dynamic>> _executeExtraction(List<Content> content) async {
    final response = await _generateContentWithFallback(content);
    final responseText = response.text;

    if (responseText == null) throw Exception("No response from AI");

    String cleanJson = responseText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return jsonDecode(cleanJson);
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
