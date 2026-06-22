import 'package:flutter/material.dart';
import '../../nucleo/temas/appCores.dart';

class CardResumoCronograma extends StatelessWidget {
  const CardResumoCronograma({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF1E8).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.folder_open, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumo do cronograma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Confira as informações antes de salvar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResumoItem(Icons.groups_outlined, 'Grupo', 'Recicla Norte'),
          _buildResumoItem(Icons.recycling, 'Tipo de coleta', 'Reciclável'),
          _buildResumoItem(Icons.calendar_today, 'Dias da semana', 'SEG, TER, QUI, SAB'),
          _buildResumoItem(Icons.access_time, 'Horário', '08:00 às 12:00'),
          _buildResumoItem(Icons.sync, 'Frequência', 'Semanal'),
          _buildResumoItem(Icons.chat_bubble_outline, 'Observações', 'Nenhuma observação adicionada'),
        ],
      ),
    );
  }

  Widget _buildResumoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PUNCCores.escuroPrimaria),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                const Divider(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
