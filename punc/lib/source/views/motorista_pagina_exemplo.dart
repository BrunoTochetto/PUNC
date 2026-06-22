import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/motorista_view_model.dart';
import '../widgets/punc_app_shell.dart';

/// Página de exemplo para gerenciar o estado do motorista (Em percurso / Inativo).
///
/// Esta página demonstra como usar o MotoristaViewModel para:
/// - Iniciar coleta de localização quando status = "Em percurso"
/// - Parar coleta quando status = "Inativo"
/// - Exibir estado reativo e erros à interface
class MotoristaPaginaExemplo extends StatefulWidget {
  const MotoristaPaginaExemplo({super.key});

  @override
  State<MotoristaPaginaExemplo> createState() => _MotoristaPaginaExemploState();
}

class _MotoristaPaginaExemploState extends State<MotoristaPaginaExemplo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Você deve obter o ID real do motorista autenticado
      // context.read<MotoristaViewModel>().definirMotorista(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color corFundoPagina = Color(0xFFD3E4D8);
    const Color corBotaoPrimario = Color(0xFF5E996E);
    const Color corTextoEscuro = Color(0xFF2C2C2C);
    const Color corErro = Color(0xFFE03B3B);

    return PuncAppShell(
      selectedRoute: '/motorista',
      body: Container(
        color: corFundoPagina,
        child: Consumer<MotoristaViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'Status do Percurso',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: corTextoEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Controle o status do seu percurso e acompanhe '
                    'o envio de localização em tempo real.',
                    style: TextStyle(
                      color: corTextoEscuro.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card com informações do motorista
                  _buildCardInformacoes(context, viewModel),

                  const SizedBox(height: 22),

                  // Card com estado de coleta
                  _buildCardEstadoColeta(context, viewModel),

                  const SizedBox(height: 28),

                  // Botões de ação
                  // "Iniciar Coleta" habilitado apenas quando estiver inativo
                  // "Finalizar" habilitado apenas quando estiver em percurso
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.estaInativo
                              ? () => _iniciarPercurso(context, viewModel)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corBotaoPrimario,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: corBotaoPrimario.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            viewModel.estaEmPercurso
                                ? 'Coleta Ativa'
                                : 'Iniciar Coleta',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: viewModel.estaEmPercurso
                              ? () => _finalizarPercurso(context, viewModel)
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: corErro,
                            disabledForegroundColor: corErro.withValues(alpha: 0.4),
                            side: BorderSide(
                              color: viewModel.estaEmPercurso
                                  ? corErro
                                  : corErro.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Finalizar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Mostrar erro se houver
                  if (viewModel.mensagemErro != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: corErro.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: corErro),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: corErro,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              viewModel.mensagemErro!,
                              style: const TextStyle(
                                color: corErro,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: viewModel.limparErro,
                            icon: const Icon(Icons.close, color: corErro),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardInformacoes(
    BuildContext context,
    MotoristaViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Motorista',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'ID do Motorista',
            viewModel.idMotorista?.toString() ?? 'Não definido',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Status',
            viewModel.estaEmPercurso ? 'Em percurso' : 'Inativo',
            cor: viewModel.estaEmPercurso
                ? const Color(0xFF4AA564)
                : const Color(0xFF999999),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEstadoColeta(
    BuildContext context,
    MotoristaViewModel viewModel,
  ) {
    final estadoColeta = _obterTextoEstadoColeta(viewModel);
    final corEstado = _obterCorEstado(viewModel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado da Coleta de Localização',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: corEstado,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  estadoColeta,
                  style: TextStyle(
                    fontSize: 14,
                    color: corEstado,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (viewModel.estaSincronizando)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF5E996E)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.estaEmPercurso
                ? 'Localização sendo coletada e enviada a cada 30 segundos.'
                : 'Clique em "Iniciar Coleta" para começar a enviar sua localização.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor, {Color cor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            color: cor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _obterTextoEstadoColeta(MotoristaViewModel viewModel) {
    if (viewModel.estaInativo) {
      return 'Coleta pausada';
    } else if (viewModel.estaSincronizando) {
      return 'Enviando localização...';
    } else {
      return 'Coletando e enviando';
    }
  }

  Color _obterCorEstado(MotoristaViewModel viewModel) {
    if (viewModel.estaInativo) {
      return const Color(0xFF999999);
    } else if (viewModel.estaSincronizando) {
      return const Color(0xFF5E996E);
    } else {
      return const Color(0xFF4AA564);
    }
  }

  Future<void> _iniciarPercurso(
    BuildContext context,
    MotoristaViewModel viewModel,
  ) async {
    final sucesso = await viewModel.iniciarPercurso();

    if (!mounted) return;

    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.mensagemErro ?? 'Erro ao iniciar percurso',
          ),
          backgroundColor: const Color(0xFFE03B3B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coleta de localização iniciada!'),
          backgroundColor: Color(0xFF4AA564),
        ),
      );
    }
  }

  Future<void> _finalizarPercurso(
    BuildContext context,
    MotoristaViewModel viewModel,
  ) async {
    final sucesso = await viewModel.finalizarPercurso();

    if (!mounted) return;

    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.mensagemErro ?? 'Erro ao finalizar percurso',
          ),
          backgroundColor: const Color(0xFFE03B3B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percurso finalizado!'),
          backgroundColor: Color(0xFF4AA564),
        ),
      );
    }
  }
}
