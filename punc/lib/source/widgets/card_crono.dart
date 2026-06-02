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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Usando a cor de superfície do tema
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Texto principal sobre superfície
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coleta: $time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6), // Texto secundário com opacidade
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
