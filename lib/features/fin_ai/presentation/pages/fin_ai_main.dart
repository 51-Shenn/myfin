import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:myfin/features/fin_ai/data/repositories/chat_repository_impl.dart';
import 'package:myfin/features/fin_ai/domain/entities/chat_message.dart';
import 'package:myfin/features/fin_ai/presentation/bloc/fin_ai_bloc.dart';

class AiChatbotScreen extends StatelessWidget {
  const AiChatbotScreen({super.key});

  final Color _primaryBlue = const Color(0xFF2B46F9);
  final Color _bgGrey = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatViewModel(ChatRepository()),
      child: Scaffold(
        backgroundColor: _bgGrey,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Chat List Area
            Expanded(
              child: BlocBuilder<ChatViewModel, ChatState>(
                builder: (context, state) {
                  // Auto-scroll logic is handled usually by a specialized widget or 
                  // by passing a controller to the ListView. For simplicity in Clean Arch,
                  // we stick to rendering the list. 
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    // If loading, add 1 extra item for the spinner
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      final msg = state.messages[index];
                      return _ChatBubble(msg: msg, primaryBlue: _primaryBlue);
                    },
                  );
                },
              ),
            ),

            // Suggestions
            _SuggestionChips(primaryBlue: _primaryBlue),

            // Input Area
            _InputArea(bgGrey: _bgGrey),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rocket_launch, color: _primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FinAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final Color primaryBlue;

  const _ChatBubble({required this.msg, required this.primaryBlue});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
            color: msg.isUser ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: msg.isUser
                  ? const Radius.circular(12)
                  : const Radius.circular(0),
              bottomRight: msg.isUser
                  ? const Radius.circular(0)
                  : const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
        child: MarkdownBody(
          data: msg.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: msg.isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
            strong: TextStyle(
              color: msg.isUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            listBullet: TextStyle(
              color: msg.isUser ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final Color primaryBlue;
  const _SuggestionChips({required this.primaryBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(context, 'Revenue forecast'),
          _buildChip(context, 'Top expenses?'),
          _buildChip(context, 'Cash flow status?'),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
        onPressed: () {
          // Access the Cubit via context
          context.read<ChatViewModel>().sendMessage(label);
        },
      ),
    );
  }
}

class _InputArea extends StatefulWidget {
  final Color bgGrey;
  const _InputArea({required this.bgGrey});

  @override
  State<_InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<_InputArea> {
  final TextEditingController _textController = TextEditingController();

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    
    // Call the ViewModel
    context.read<ChatViewModel>().sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.bgGrey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask about your finances...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: widget.bgGrey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.grey[600]),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

// hide nav bar
// NavBarController.of(context)?.toggleNavBar();