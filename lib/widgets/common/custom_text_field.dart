import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool isDateField;
  final VoidCallback? onDateTap;
  final String? hintText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.isDateField = false,
    this.onDateTap,
    this.hintText,
    this.validator,
  });

  static const Color primaryColor = Color(0xFF005A9C);
  static const Color cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final consistentDecoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: cardBackgroundColor,
      alignLabelWithHint: maxLines != 1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      suffixIcon: isDateField
          ? IconButton(
              icon: const Icon(Icons.calendar_today, color: primaryColor),
              onPressed: onDateTap, // buka showDatePicker
            )
          : null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: isDateField,
        onTap: isDateField ? onDateTap : null,
        validator: validator,
        style: const TextStyle(color: Colors.black87),
        decoration: consistentDecoration,
        inputFormatters: null,
      ),
    );
  }
}
