import 'package:flutter/material.dart';

import '../data/modelos/tipo_lixo.dart';

/// Seletor de tipo de coleta (apenas orgânico ou reciclado).
class SeletorTipoColeta extends StatelessWidget {
  const SeletorTipoColeta({
    super.key,
    required this.valorSelecionado,
    required this.onChanged,
    this.habilitado = true,
  });

  final String? valorSelecionado;
  final ValueChanged<String> onChanged;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOpcao(
            valor: TipoLixo.organico,
            label: TipoLixo.rotulos[TipoLixo.organico]!,
            icon: Icons.eco_outlined,
            color: const Color(0xFF8B4513),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOpcao(
            valor: TipoLixo.reciclado,
            label: TipoLixo.rotulos[TipoLixo.reciclado]!,
            icon: Icons.recycling,
            color: const Color(0xFF4AA564),
          ),
        ),
      ],
    );
  }

  Widget _buildOpcao({
    required String valor,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final selecionado = valorSelecionado == valor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: habilitado ? () => onChanged(valor) : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selecionado ? color.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selecionado ? color : Colors.grey.shade300,
              width: selecionado ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: habilitado ? color : color.withValues(alpha: 0.45),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                  color: habilitado
                      ? (selecionado ? color : Colors.grey.shade700)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
