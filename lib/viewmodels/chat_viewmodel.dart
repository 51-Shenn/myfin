import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/repository/chat_repo.dart';
import 'package:myfin/datamodels/chat_message.dart';

// State
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({required this.messages, this.isLoading = false, this.error});

  factory ChatState.initial() => ChatState(messages: [
    ChatMessage(text: "Hello! I'm FinAI. How can I help?", isUser: false)
  ]);
}

// Cubit
class ChatViewModel extends Cubit<ChatState> {
  final ChatRepository _repo;

  ChatViewModel(this._repo) : super(ChatState.initial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message & Set Loading
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(text: text, isUser: true));
    
    emit(ChatState(messages: updatedMessages, isLoading: true));

    try {
      // 2. Call Repo
      final responseText = await _repo.sendMessage(text);

      // 3. Add AI Response & Stop Loading
      final finalMessages = List<ChatMessage>.from(state.messages)
        ..add(ChatMessage(text: responseText, isUser: false));

      emit(ChatState(messages: finalMessages, isLoading: false));
    } catch (e) {
      emit(ChatState(
        messages: state.messages, 
        isLoading: false, 
        error: e.toString()
      ));
    }
  }
}