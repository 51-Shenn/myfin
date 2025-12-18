import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfin/features/fin_ai/data/repositories/chat_repository_impl.dart';
import 'package:myfin/features/fin_ai/domain/entities/chat_message.dart';

// --- STATE ---
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading; // For message sending
  final bool isInitializing; // For loading initial data from Firebase
  final String? error;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.isInitializing = false,
    this.error,
  });

  factory ChatState.initial() => ChatState(
    messages: [],
    isInitializing: true, // Start in initializing state
  );
  
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isInitializing,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
    );
  }
}

// --- BLOC (CUBIT) ---
class ChatViewModel extends Cubit<ChatState> {
  final ChatRepository _repo;

  ChatViewModel(this._repo) : super(ChatState.initial()) {
    _init(); // Automatically start the process
  }

  // This is where the automatic data fetching happens
  Future<void> _init() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(state.copyWith(isInitializing: false, error: "User not logged in."));
        return;
      }

      // Tell the repository to fetch data and prepare the AI
      await _repo.initializeSession(user.uid);

      // Once done, show a greeting message
      final initialMessages = [
        ChatMessage(
          text: "Hello! I've analyzed your recent documents from Firebase. How can I help you today?", 
          isUser: false
        )
      ];

      emit(state.copyWith(messages: initialMessages, isInitializing: false));
    } catch (e) {
      emit(state.copyWith(isInitializing: false, error: e.toString()));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(text: text, isUser: true));
    
    emit(state.copyWith(messages: updatedMessages, isLoading: true));

    try {
      final responseText = await _repo.sendMessage(text);

      final finalMessages = List<ChatMessage>.from(state.messages)
        ..add(ChatMessage(text: text, isUser: true)) // Ensure user message is kept
        ..add(ChatMessage(text: responseText, isUser: false));

      emit(state.copyWith(messages: finalMessages, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}