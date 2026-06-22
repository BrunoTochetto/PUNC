import 'package:flutter/material.dart';

class BarraBuscaMapa extends StatelessWidget {
  const BarraBuscaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 30, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sua localização',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Text(
                  'Rua 3 de Outubro, 811\nCentro - São Lourenço do Oeste/SC',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Raio de busca',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Row(
                children: const [
                  Text(
                    '5 km',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.center_focus_strong, color: Colors.black54),
        ],
      ),
    );
  }
}
