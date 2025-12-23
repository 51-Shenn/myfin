import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:myfin/features/upload/data/datasources/firestore_document_data_source.dart';
import 'package:myfin/features/upload/data/datasources/firestore_doc_line_data_source.dart';
import 'package:myfin/features/report/data/datasources/report_remote_data_source.dart';

class ChatRepository {
  final FirestoreDocumentDataSource _docDataSource;
  final FirestoreDocumentLineItemDataSource _lineDataSource;
  final FirestoreReportDataSource _reportDataSource;

  List<Content> _history = [];
  Content? _systemInstruction;
  bool _isInitialized = false;

  final List<String> _modelsToTry = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-3-flash-preview',
  ];

  ChatRepository({
    required FirestoreDocumentDataSource docDataSource,
    required FirestoreDocumentLineItemDataSource lineDataSource,
    required FirestoreReportDataSource reportDataSource,
  })  : _docDataSource = docDataSource,
        _lineDataSource = lineDataSource,
        _reportDataSource = reportDataSource;

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

  Future<void> initializeSession(String memberId) async {
    final documentContext = await _buildDocumentContext(memberId);
    final reportContext = await _buildReportContext(memberId);

    // UPDATED PROMPT LOGIC HERE
    _systemInstruction = Content.text('''
      You are FinAI, an expert financial assistant.
      
      Here is the user's financial data (Raw Database Records):

      === GENERATED REPORTS (Sorted: NEWEST FIRST) ===
      $reportContext

      === RECENT UPLOADED DOCUMENTS ===
      $documentContext

      INSTRUCTIONS:
      1. **PRIORITY RULE:** The "GENERATED REPORTS" section is sorted by date (Newest at the top).
      2. If multiple reports of the same type exist (e.g., 5 Balance Sheets), **ONLY use the FIRST/TOP-MOST report** of that type to answer questions about the "current" status.
      3. **IGNORE older reports** of the same type unless the user specifically asks for a history comparison or a specific past date.
      4. If the latest report shows 0.0 for a value, state that the *latest generated report* shows 0.
      5. The "UPLOADED DOCUMENTS" contain specific transaction details. Use these to explain *why* the report figures might be what they are.
      6. Be concise and professional.
    ''');

    _history = [];
    _isInitialized = true;
  }

  Future<String> sendMessage(String message) async {
    if (!_isInitialized || _systemInstruction == null) {
      throw Exception("Chat session is not ready. Call initializeSession first.");
    }

    final keys = _getApiKeys();
    if (keys.isEmpty) throw Exception("No API keys found.");

    Object? lastError;

    for (String apiKey in keys) {
      for (String modelName in _modelsToTry) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
            systemInstruction: _systemInstruction,
          );

          final chatSession = model.startChat(history: _history);
          final response = await chatSession.sendMessage(Content.text(message));
          final responseText = response.text;

          if (responseText == null) throw Exception("Empty response");

          _history = chatSession.history.toList();
          return responseText;
        } catch (e) {
          print("FinAI Failed ($modelName): $e");
          lastError = e;
          continue;
        }
      }
    }
    throw Exception("All AI models failed. Last error: $lastError");
  }

  Future<String> _buildDocumentContext(String memberId) async {
    try {
      final docs = await _docDataSource.getDocuments(
        filters: {'memberId': memberId},
        limit: 30,
      );

      if (docs.isEmpty) return "No uploaded documents found.";

      final StringBuffer buffer = StringBuffer();

      for (var doc in docs) {
        final docId = doc['id'];
        final lines = await _lineDataSource.getLineItemsByDocumentId(docId);
        
        double docTotal = lines.fold(0.0, (sum, item) {
          return sum + ((item['total'] as num?)?.toDouble() ?? 0.0);
        });

        String dateStr = "?";
        if (doc['postingDate'] is Timestamp) {
          dateStr = (doc['postingDate'] as Timestamp).toDate().toIso8601String().split('T')[0];
        }

        buffer.writeln(
          "- Document: '${doc['name']}' (Type: ${doc['type']}, Date: $dateStr, Total: $docTotal)"
        );

        if (lines.isNotEmpty) {
          final displayLines = lines.take(3);
          buffer.writeln("  - Details: ${displayLines.map((e) => "'${e['description']}' (${e['total']})").join(', ')}");
        }
      }
      return buffer.toString();
    } catch (e) {
      print("Document Context Error: $e");
      return "Error loading document data.";
    }
  }

  Future<String> _buildReportContext(String memberId) async {
    try {
      // 1. Fetch Raw Maps directly
      final reports = await _reportDataSource.getReportsByMemberId(memberId);

      if (reports.isEmpty) return "No generated reports found.";

      final StringBuffer buffer = StringBuffer();
      
      // CHANGED LIMIT FROM 5 TO 15
      final recentReports = reports.take(15); 

      int index = 1;
      for (var report in recentReports) {
        final String type = report['report_type'] ?? 'Unknown';
        
        String generatedDate = 'Unknown';
        if (report['generated_at'] is Timestamp) {
          generatedDate = (report['generated_at'] as Timestamp).toDate().toIso8601String().split('T')[0];
        }

        String periodStr = 'Unknown';
        try {
          if (report['fiscal_period'] is String) {
            final Map<String, dynamic> periodMap = jsonDecode(report['fiscal_period']);
            final start = periodMap['startDate']?.toString().split('T')[0] ?? '?';
            final end = periodMap['endDate']?.toString().split('T')[0] ?? '?';
            periodStr = "$start to $end";
          }
        } catch (_) {}

        // Add explicit "LATEST" tag to the very first item processed
        // Since Firebase returns descending order, the first item is naturally the latest.
        String latestTag = (index == 1) ? " [LATEST REPORT]" : "";

        buffer.writeln("Report #$index: $type$latestTag");
        buffer.writeln("  Generated: $generatedDate");
        buffer.writeln("  Period: $periodStr");

        String val(String key) => report[key]?.toString() ?? "0";

        if (type.contains('Profit')) {
          buffer.writeln("  > Gross Profit: ${val('gross_profit')}");
          buffer.writeln("  > Total Expenses: ${val('total_expenses')}");
          buffer.writeln("  > Net Income: ${val('net_income')}");
        } else if (type.contains('Balance')) {
          buffer.writeln("  > Total Assets: ${val('total_assets')}");
          buffer.writeln("  > Total Liabilities: ${val('total_liabilities')}");
          buffer.writeln("  > Total Equity: ${val('total_equity')}");
        } else if (type.contains('Cash Flow')) {
          buffer.writeln("  > Operating Cash Flow: ${val('total_operating_cash_flow')}");
          buffer.writeln("  > Net Cash Change: ${val('cash_balance')}");
        } else if (type.contains('Receivable')) {
          buffer.writeln("  > Total Receivable: ${val('total_receivable')}");
          buffer.writeln("  > Overdue: ${val('total_overdue')}");
        } else if (type.contains('Payable')) {
          buffer.writeln("  > Total Payable: ${val('total_payable')}");
          buffer.writeln("  > Overdue: ${val('total_overdue')}");
        }
        buffer.writeln("");
        index++;
      }
      return buffer.toString();
    } catch (e) {
      print("Report Context Error: $e");
      return "Error loading report data.";
    }
  }
}