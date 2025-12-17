import 'package:flutter/material.dart';
import 'package:myfin/features/upload/presentation/pages/doc_field_header.dart';

class DocTextFormField extends StatelessWidget {
  final DocFieldHeader header;
  final String? value;
  final bool readOnly;
  final bool isAdditional;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool multiLine;
  final VoidCallback? onTap;
  final bool isDate;

  const DocTextFormField({
    super.key,
    required this.header,
    this.value,
    this.readOnly = false,
    this.isAdditional = false,
    this.onChanged,
    this.validator,
    this.multiLine = false,
    this.onTap,
    this.isDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdditional)
            Text(
              '${header.fieldName}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(height: 5),
          TextFormField(
            key: isDate ? ValueKey(value) : null,
            initialValue: value,
            readOnly: readOnly || isDate,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator,
            minLines: multiLine ? 3 : 1,
            maxLines: multiLine ? 5 : 1,
            keyboardType: multiLine
                ? TextInputType.multiline
                : TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: isDate
                  ? const Icon(Icons.calendar_today, size: 20)
                  : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}