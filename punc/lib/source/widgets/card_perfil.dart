import 'package:flutter/material.dart';

class CardPerfil extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Map<String, String>> details;

  const CardPerfil({
    super.key,
    required this.icon,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    // Cores Forçadas para Branco Puro e Bordas Cinzas (Identidade Figma)
    const Color corCardBranco = Colors.white;
    const Color corBordaCinza = Color(0xFFE0E0E0);
    const Color corIconeVerde = Color(0xFF5E996E); // Verde folha suave do design
    const Color corTextoPrincipal = Color(0xFF2C2C2C);

    return Container(
      decoration: BoxDecoration(
        color: corCardBranco, // Branco Puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBordaCinza), // Borda Cinza Clara
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: corIconeVerde, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: corTextoPrincipal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        detail.keys.first,
                        style: TextStyle(
                          color: corTextoPrincipal.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.values.first,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: corTextoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
