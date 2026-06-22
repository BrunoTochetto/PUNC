import 'package:flutter/material.dart';

class CardCrono extends StatelessWidget {
  final String day;
  final String time;
  final String type;
  final Color iconColor;

  const CardCrono({
    super.key,
    required this.day,
    required this.time,
    required this.type,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color corCardBranco = colorScheme.surface; 
    final Color corBordaCinza = colorScheme.onSurface;
    final Color corTextoPrincipal = colorScheme.onSurface;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corCardBranco, // Forçado para Branco Puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBordaCinza), // Adicionada borda cinza clara
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: corTextoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coleta: $time',
                  style: TextStyle(
                    color: corTextoPrincipal.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.recycling,
                color: iconColor,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: corTextoPrincipal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
