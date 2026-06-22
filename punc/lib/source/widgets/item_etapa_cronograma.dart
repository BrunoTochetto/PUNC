import 'package:flutter/material.dart';
import '../../nucleo/temas/appCores.dart';

class ItemEtapaCronograma extends StatelessWidget {
  final String numero;
  final String titulo;
  final Widget conteudo;
  final bool mostrarLinha;

  const ItemEtapaCronograma({
    super.key,
    required this.numero,
    required this.titulo,
    required this.conteudo,
    this.mostrarLinha = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: PUNCCores.escuroPrimaria,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    numero,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (mostrarLinha)
                Expanded(
                  child: Container(
                    width: 2,
                    color: PUNCCores.escuroPrimaria.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                conteudo,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
