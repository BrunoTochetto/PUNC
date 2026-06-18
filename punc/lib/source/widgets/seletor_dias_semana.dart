import 'package:flutter/material.dart';
import '../../nucleo/temas/appCores.dart';

class SeletorDiasSemana extends StatelessWidget {
  const SeletorDiasSemana({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDia('SEG', true),
            _buildDia('TER', true),
            _buildDia('QUA', false),
            _buildDia('QUI', true),
            _buildDia('SEX', false),
            _buildDia('SAB', true),
            _buildDia('DOM', false),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.info_outline, size: 14, color: Colors.black),
            SizedBox(width: 4),
            Text('Selecione um ou mais dias para o cronograma', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildDia(String dia, bool isSelected) {
    return Container(
      width: 40,
      height: 45,
      decoration: BoxDecoration(
        color: isSelected ? PUNCCores.escuroPrimaria.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? PUNCCores.escuroPrimaria : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dia, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          if (isSelected) Icon(Icons.check_circle, size: 14, color: PUNCCores.escuroPrimaria),
        ],
      ),
    );
  }
}
