import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/modelos/tipo_lixo.dart';
import '../viewmodels/motorista_view_model.dart';
import 'seletor_tipo_coleta.dart';

/// Painel flutuante no mapa para o motorista ligar/desligar a rota.
class PainelControleMotorista extends StatefulWidget {
  const PainelControleMotorista({super.key});

  @override
  State<PainelControleMotorista> createState() =>
      _PainelControleMotoristaState();
}

class _PainelControleMotoristaState extends State<PainelControleMotorista> {
  final TextEditingController _identificacaoController =
      TextEditingController();
  int? _motoristaSincronizado;

  @override
  void dispose() {
    _identificacaoController.dispose();
    super.dispose();
  }

  void _sincronizarIdentificacao(MotoristaViewModel motorista) {
    final id = motorista.idMotorista;
    if (id == null) return;

    if (_motoristaSincronizado != id) {
      _motoristaSincronizado = id;
      _identificacaoController.text =
          motorista.identificacaoCaminhaoSelecionada ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MotoristaViewModel>(
      builder: (context, motorista, _) {
        if (!motorista.ehMotorista) {
          return const SizedBox.shrink();
        }

        _sincronizarIdentificacao(motorista);

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
                if (!emPercurso) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _identificacaoController,
                    enabled: !motorista.estaSincronizando,
                    maxLength: 255,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Identificação do caminhão',
                      hintText: 'Ex.: Caminhão 01',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: motorista.definirIdentificacaoCaminhao,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tipo de lixo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SeletorTipoColeta(
                    valorSelecionado: motorista.tipoLixoSelecionado,
                    onChanged: motorista.definirTipoLixo,
                    habilitado: !motorista.estaSincronizando,
                  ),
                ] else ...[
                  if (motorista.identificacaoCaminhaoExibicao != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Caminhão: ${motorista.identificacaoCaminhaoExibicao}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (motorista.tipoLixoExibicao != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Coletando: ${motorista.tipoLixoExibicao}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                if (emPercurso) ...[
                  Text(
                    'Percurso ativo — enviando localização',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: motorista.estaSincronizando
                          ? null
                          : () => _alternarRota(context, motorista, false),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: motorista.estaSincronizando
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onError,
                              ),
                            )
                          : const Text('Terminar percurso'),
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Percurso desligado',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Switch.adaptive(
                        value: false,
                        onChanged: motorista.estaSincronizando
                            ? null
                            : (ativo) =>
                                _alternarRota(context, motorista, ativo),
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

    if (ativar) {
      motorista.definirIdentificacaoCaminhao(_identificacaoController.text);

      if (motorista.identificacaoCaminhaoSelecionada?.isNotEmpty != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Informe a identificação do caminhão antes de iniciar o percurso.',
            ),
          ),
        );
        return;
      }

      if (motorista.tipoLixoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione o tipo de lixo antes de iniciar o percurso.'),
          ),
        );
        return;
      }

      final confirmado = await _confirmarInicioRota(
        context,
        identificacao: motorista.identificacaoCaminhaoSelecionada!,
        tipoLixo: motorista.tipoLixoSelecionado!,
      );
      if (!confirmado || !context.mounted) return;
    }

    final sucesso = ativar
        ? await motorista.iniciarPercurso()
        : await motorista.finalizarPercurso();

    if (!context.mounted || sucesso) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          motorista.mensagemErro ??
              (ativar
                  ? 'Não foi possível iniciar o percurso.'
                  : 'Não foi possível desligar o percurso.'),
        ),
      ),
    );
  }

  Future<bool> _confirmarInicioRota(
    BuildContext context, {
    required String identificacao,
    required String tipoLixo,
  }) async {
    final rotulo = TipoLixo.rotulo(tipoLixo);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Iniciar percurso?'),
          content: Text(
            'Confirma o início do percurso do caminhão "$identificacao" '
            'para coleta de lixo $rotulo?\n\n'
            'Sua localização será enviada em segundo plano enquanto o percurso '
            'estiver ativo, com a notificação "Percurso ativo".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Iniciar percurso'),
            ),
          ],
        );
      },
    );

    return confirmado ?? false;
  }
}
