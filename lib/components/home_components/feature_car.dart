import 'package:flutter/material.dart';

class FeatureCar extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeatureCar({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Icon(icon, size: 16, color: Colors.black),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
