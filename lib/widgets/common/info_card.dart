import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color color;
  final Color titleColor;
  final Color dividerColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.children,
    this.color = Colors.white,
    this.titleColor = const Color(0xFF005A9C),
    this.dividerColor = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            Divider(height: 24, thickness: 0.5, color: dividerColor),
            ...children,
          ],
        ),
      ),
    );
  }
}