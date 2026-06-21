import 'package:flutter/material.dart';

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key});

  @override
  Widget build(BuildContext context) {
    // Cor de destaque do Figma (Verde Água/Ciano)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color corDestaque = colorScheme.primary;

    return Center(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color corErro = colorScheme.error; // Vermelho suave
    final Color corTexto = colorScheme.onSurface;
    final Color corBotao = colorScheme.primary;
    final Color corTextoBotao = colorScheme.onPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: corErro.withValues(alpha: 0.9),
            ),
            SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corTexto.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTentarNovamente != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onTentarNovamente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corBotao.withValues(alpha: 0.9),
                  foregroundColor: corTextoBotao.withValues(alpha: 0.9),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color corTexto = colorScheme.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.satellite_alt_rounded,

              size: 56,
              color: corTexto.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corTexto.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
