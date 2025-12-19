import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
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

  Future<void> initializeSession(String memberId) async {
    final apiKey = dotenv.env['GEMINI_API_KEY_4'] ?? "";
    
    final contextString = await _buildFinancialContext(memberId);

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