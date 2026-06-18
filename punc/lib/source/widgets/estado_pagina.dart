import 'package:flutter/material.dart';

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key});

  @override
  Widget build(BuildContext context) {
    // Cor de destaque do Figma (Verde Água/Ciano)
    const Color corDestaque = Color(0xFF5BA7B4);

    return const Center(
      child: CircularProgressIndicator(
        color: corDestaque,
        strokeWidth: 3,
      ),
    );
  }
}

class EstadoErro extends StatelessWidget {
  const EstadoErro({
    super.key,
    required this.mensagem,
    this.onTentarNovamente,
  });

  final String mensagem;
  final VoidCallback? onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    const Color corErro = Color(0xFFE57373); // Vermelho suave
    const Color corTexto = Color(0xFF2C2C2C);
    const Color corBotao = Color(0xFF5E996E); // Verde folha suave

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: corErro,
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: corTexto,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTentarNovamente != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onTentarNovamente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corBotao,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tentar novamente', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.mensagem,
  });

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    const Color corTexto = Color(0xFF2C2C2C);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: corTexto.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corTexto.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
