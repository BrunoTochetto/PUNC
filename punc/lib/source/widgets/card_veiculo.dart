import 'package:flutter/material.dart';

class CardVeiculo extends StatelessWidget {
  final String title;
  final String driver;
  final String plate;
  final String phone;
  final String status;
  final Color statusColor;
  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CardVeiculo({
    super.key,
    required this.title,
    required this.driver,
    required this.plate,
    required this.phone,
    required this.status,
    required this.statusColor,
    this.onDetails,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Cores Forçadas para Branco Puro e Bordas Cinzas (Identidade Figma)
    const Color corCardBranco = Colors.white;
    const Color corBordaCinza = Color(0xFFE0E0E0);
    const Color corTextoPrincipal = Color(0xFF2C2C2C);
    const Color corIconeDestaque = Color(0xFF5BA7B4); // Verde água vibrante do design

    return Container(
      decoration: BoxDecoration(
        color: corCardBranco, // Branco Puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: corBordaCinza), // Borda Cinza Clara
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem/Ícone do Caminhão
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: corIconeDestaque.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: corIconeDestaque.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: corIconeDestaque,
                  size: 48,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações Centrais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: corTextoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Motorista: $driver',
                      style: TextStyle(
                        color: corTextoPrincipal.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Placa: $plate',
                      style: TextStyle(
                        color: corTextoPrincipal.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: corIconeDestaque,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: corIconeDestaque,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status (Canto Superior Direito)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: corBordaCinza, height: 1),
          const SizedBox(height: 8),
          
          // Botões de Ação (Rodapé do Card)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'Ver detalhes',
                onPressed: onDetails ?? () {},
              ),
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Editar',
                onPressed: onEdit ?? () {},
              ),
              _buildActionButton(
                icon: Icons.delete_outline,
                label: 'Excluir',
                textColor: const Color(0xFFE57373), // Vermelho suave para excluir
                onPressed: onDelete ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? textColor,
  }) {
    final color = textColor ?? const Color(0xFF2C2C2C).withValues(alpha: 0.5);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
