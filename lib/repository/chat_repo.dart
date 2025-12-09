import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRepository {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  ChatRepository() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? "No response received.";
    } catch (e) {
      throw Exception('Failed to communicate with AI: $e');
    }
  }
}