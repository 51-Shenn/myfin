import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// --- DATA SOURCE IMPORTS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/features/report/data/datasources/report_remote_data_source.dart';
import 'package:myfin/features/upload/data/datasources/firestore_document_data_source.dart';
import 'package:myfin/features/upload/data/datasources/firestore_doc_line_data_source.dart';
// ---------------------------

import 'package:myfin/features/fin_ai/data/repositories/chat_repository_impl.dart';
import 'package:myfin/features/fin_ai/domain/entities/chat_message.dart';
import 'package:myfin/features/fin_ai/presentation/bloc/fin_ai_bloc.dart';

class AiChatbotScreen extends StatelessWidget {
  const AiChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final firestore = FirebaseFirestore.instance;
        
        return ChatViewModel(
          ChatRepository(
            // 1. Report Data Source
            reportDataSource: FirestoreReportDataSource(
              firestore: firestore,
            ),
            // 2. Document Data Source
            docDataSource: FirestoreDocumentDataSource(
              firestore: firestore,
            ),
            // 3. Line Item Data Source (Required to calculate document totals and see details)
            lineDataSource: FirestoreDocumentLineItemDataSource(
              firestore: firestore,
            ),
          ),
        );
      },
      child: const _AiInfoDashboardView(),
    );
  }
}

// ... Rest of the file (_AiInfoDashboardView, _ChatInterface, etc.) remains exactly the same ...
class _AiInfoDashboardView extends StatelessWidget {
  const _AiInfoDashboardView();

  final Color _primaryBlue = const Color(0xFF2B46F9);
  final Color _bgGrey = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Financial Insights',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiDashboardSummary(),
            const SizedBox(height: 24),
            const Text(
              'Financial Knowledge Base',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Profit & Loss (P&L)",
              icon: Icons.trending_up,
              color: Colors.green,
              description: "Summarizes revenues, costs, and expenses incurred during a specific period.",
            ),
            _buildInfoCard(
              title: "Balance Sheet",
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
              description: "A snapshot of assets, liabilities, and equity at a specific point in time.",
            ),
            _buildInfoCard(
              title: "Cash Flow",
              icon: Icons.loop,
              color: Colors.blue,
              description: "Tracks the flow of cash in and out. Essential for understanding liquidity.",
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryBlue,
        onPressed: () => _showChatModal(context),
        icon: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        label: const Text("Ask FinAI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showChatModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: parentContext.read<ChatViewModel>(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                _buildModalHeader(context),
                Expanded(
                  child: _ChatInterface(primaryBlue: _primaryBlue, bgGrey: _bgGrey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.smart_toy, color: _primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FinAI Assistant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              Text('Powered by Gemini', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400]),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _buildAiDashboardSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, const Color(0xFF536DFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "FinAI Overview",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "I can analyze your uploaded documents to answer questions about:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DashboardChip(label: "Total Revenue"),
              _DashboardChip(label: "Expense Breakdown"),
              _DashboardChip(label: "Net Profit"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description, required IconData icon, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ChatInterface extends StatelessWidget {
  final Color primaryBlue;
  final Color bgGrey;

  const _ChatInterface({required this.primaryBlue, required this.bgGrey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatViewModel, ChatState>(
      builder: (context, state) {
        if (state.isInitializing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text("Analyzing your financial documents...", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: state.messages.isEmpty
                  ? Center(child: Text("Start a conversation...", style: TextStyle(color: Colors.grey[400])))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.messages.length) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          );
                        }
                        return _ChatBubble(msg: state.messages[index], primaryBlue: primaryBlue);
                      },
                    ),
            ),
            _SuggestionChips(primaryBlue: primaryBlue),
            _InputArea(bgGrey: bgGrey, primaryBlue: primaryBlue),
          ],
        );
      },
    );
  }
}

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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: msg.isUser ? primaryBlue : const Color(0xFFF1F3F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: MarkdownBody(
          data: msg.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.5),
            strong: TextStyle(color: msg.isUser ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
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
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(context, 'What was my total revenue?'),
          _buildChip(context, 'Summarize my expenses'),
          _buildChip(context, 'What is my net profit?'),
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
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
        onPressed: () => context.read<ChatViewModel>().sendMessage(label),
      ),
    );
  }
}

class _InputArea extends StatefulWidget {
  final Color bgGrey;
  final Color primaryBlue;
  const _InputArea({required this.bgGrey, required this.primaryBlue});

  @override
  State<_InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<_InputArea> {
  final TextEditingController _textController = TextEditingController();

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    context.read<ChatViewModel>().sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.bgGrey,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask about your finances...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: widget.primaryBlue,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardChip extends StatelessWidget {
  final String label;
  const _DashboardChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}