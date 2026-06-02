import 'package:flutter/material.dart';

class PinMapa extends StatelessWidget {
  final Color cor;
  final double top;
  final double left;

  const PinMapa({
    super.key,
    required this.cor,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.location_on,
        color: cor,
        size: 35,
      ),
    );
  }
}
