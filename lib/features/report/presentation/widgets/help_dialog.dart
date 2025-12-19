import 'package:flutter/material.dart';

/// Reusable help dialog for report pages
class ReportHelpDialog extends StatelessWidget {
  final String reportType;
  final String title;
  final List<HelpSection> sections;

  const ReportHelpDialog({
    super.key,
    required this.reportType,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [...sections.map((section) => _buildSection(section))],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('GOT IT'),
        ),
      ],
    );
  }

  Widget _buildSection(HelpSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Text(
              section.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (section.content != null)
            Text(
              section.content!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          if (section.items != null && section.items!.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...section.items!.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.icon != null) ...[
                      Text(item.icon!, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show help dialog
  static void show(
    BuildContext context, {
    required String reportType,
    required String title,
    required List<HelpSection> sections,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportHelpDialog(
        reportType: reportType,
        title: title,
        sections: sections,
      ),
    );
  }
}

/// Help section model
class HelpSection {
  final String? title;
  final String? content;
  final List<HelpItem>? items;

  const HelpSection({this.title, this.content, this.items});
}

/// Help item model
class HelpItem {
  final String? icon;
  final String text;

  const HelpItem({this.icon, required this.text});
}
