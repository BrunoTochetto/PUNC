import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/motorista_view_model.dart';

/// Painel flutuante no mapa para o motorista ligar/desligar a rota.
class PainelControleMotorista extends StatelessWidget {
  const PainelControleMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MotoristaViewModel>(
      builder: (context, motorista, _) {
        if (!motorista.ehMotorista) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final emPercurso = motorista.estaEmPercurso;

        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: emPercurso
                          ? colorScheme.secondary
                          : colorScheme.outline,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo motorista',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            motorista.nomeDispositivo ?? 'Seu dispositivo',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (motorista.estaSincronizando)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        emPercurso
                            ? 'Rota ativa — enviando localização'
                            : 'Rota desligada',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Switch.adaptive(
                      value: emPercurso,
                      onChanged: motorista.estaSincronizando
                          ? null
                          : (ativo) => _alternarRota(context, motorista, ativo),
                    ),
                  ],
                ),
                if (motorista.mensagemErro != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    motorista.mensagemErro!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _alternarRota(
    BuildContext context,
    MotoristaViewModel motorista,
    bool ativar,
  ) async {
    motorista.limparErro();

    final sucesso = ativar
        ? await motorista.iniciarPercurso()
        : await motorista.finalizarPercurso();

    if (!context.mounted || sucesso) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          motorista.mensagemErro ??
              (ativar
                  ? 'Não foi possível iniciar a rota.'
                  : 'Não foi possível desligar a rota.'),
        ),
      ),
    );
  }
}
