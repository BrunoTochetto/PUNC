import 'package:flutter/material.dart';

class SettingSwitch extends StatefulWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
  });

  @override
  State<SettingSwitch> createState() => _SettingSwitchState();
}

class _SettingSwitchState extends State<SettingSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _value,
              onChanged: (newValue) {
                setState(() => _value = newValue);
                widget.onChanged?.call(newValue);
              },
              activeThumbColor: const Color(0xFF4A6A64),
            ),
          ),
        ],
      ),
    );
  }
}