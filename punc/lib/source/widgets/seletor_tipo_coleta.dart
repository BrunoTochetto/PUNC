import 'package:flutter/material.dart';
import '../../nucleo/temas/appCores.dart';

class SeletorTipoColeta extends StatelessWidget {
  const SeletorTipoColeta({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOpcao('Reciclável', Icons.recycling, Colors.green, true),
        _buildOpcao('Orgânico', Icons.apple, Colors.brown, false),
        _buildOpcao('Rejeitos', Icons.delete_outline, Colors.grey, false),
      ],
    );
  }

  Widget _buildOpcao(String label, IconData icon, Color color, bool isSelected) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? color : Colors.grey)),
        ],
      ),
    );
  }
}
