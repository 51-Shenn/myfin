import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
// FIX 1: Corrected the import path from 'package.' to 'package:'
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';

class ChatRepository {
  final DocumentRepository _docRepo;
  final DocumentLineItemRepository _lineRepo;
  
  late GenerativeModel _model;
  late ChatSession _chatSession;
  bool _isInitialized = false;

  ChatRepository({
    required DocumentRepository docRepo,
    required DocumentLineItemRepository lineRepo,
  })  : _docRepo = docRepo,
        _lineRepo = lineRepo;

  /// Initializes the chat session by loading user data and setting the system prompt.
  Future<void> initializeSession(String memberId) async {
    final apiKey = dotenv.env['GEMINI_API_KEY_4'] ?? "";
    
    // 1. Fetch data from Firestore and format it as text
    final contextString = await _buildFinancialContext(memberId);

    // 2. Create the "System Instruction" for the AI
    final systemPrompt = Content.text('''
      You are FinAI, an expert financial assistant.
      
      Here is the user's current financial data from their Firebase document collection:
      $contextString

      INSTRUCTIONS:
      1. Use ONLY the provided data to answer questions.
      2. If the data says "No documents found", tell the user to upload documents first.
      3. Be concise and professional.
      4. Do not invent information. If the data is insufficient, state that.
    ''');

    // 3. Initialize the AI Model with this context
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: systemPrompt,
    );

    _chatSession = _model.startChat();
    _isInitialized = true;
  }

  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      throw Exception("Chat session is not ready.");
    }

    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      print("GEMINI ERROR: $e");
      throw Exception('Failed to communicate with AI: $e');
    }
  }

  // This is the core data-fetching logic
  Future<String> _buildFinancialContext(String memberId) async {
    try {
      final docs = await _docRepo.getDocuments(memberId: memberId, limit: 25);

      if (docs.isEmpty) return "No documents found.";

      final StringBuffer buffer = StringBuffer();
      buffer.writeln("--- SUMMARY OF RECENT FINANCIAL DOCUMENTS ---");

      for (var doc in docs) {
        final lines = await _lineRepo.getLineItemsByDocumentId(doc.id);
        double docTotal = lines.fold(0, (sum, item) => sum + item.total);

        buffer.writeln(
          // FIX 2: Corrected the method name from 'toIso8101String' to 'toIso8601String'
          "- Document: '${doc.name}' (Type: ${doc.type}, Date: ${doc.postingDate.toIso8601String().split('T')[0]}, Total: $docTotal)"
        );
        
        if (lines.isNotEmpty) {
          buffer.writeln("  - Items: ${lines.map((e) => "'${e.description}' (${e.total})").join(', ')}");
        }
      }

      return buffer.toString();
    } catch (e) {
      print("Context building error: $e");
      return "Error loading financial data from Firebase.";
    }
  }
}