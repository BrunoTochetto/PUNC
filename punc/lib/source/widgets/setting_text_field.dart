import 'package:flutter/material.dart';

class SettingTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final IconData? suffixIcon;

  const SettingTextField({
    super.key,
    required this.label,
    required this.initialValue,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    initialValue,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (suffixIcon != null)
                    Icon(suffixIcon, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
