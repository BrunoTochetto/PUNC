import 'package:flutter/material.dart';

import '../data/servicos/servico_preferencias_usuario.dart';
import '../viewmodels/localizacao_view_model.dart';

class DebugNotificacoesPage extends StatelessWidget {
  const DebugNotificacoesPage({
    super.key,
    this.resultado,
  });

  final ResultadoConfiguracaoLocalizacao? resultado;

  @override
  Widget build(BuildContext context) {
    final resultadoAtual = resultado;
    if (resultadoAtual == null) {
      return const _DebugPreferenciasPage();
    }

    final usuario = resultadoAtual.cadastro.usuario;
    final celula = usuario.celula;
    final inscricaoBackend = usuario.inscricaoFcm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Depuracao de notificacoes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SecaoDebug(
            titulo: 'Status',
            itens: {
              'Cadastro backend': resultadoAtual.cadastro.mensagem,
              'Topico inscrito no front': resultadoAtual.inscricao.topico,
              'Inscricao Firebase': resultadoAtual.inscricao.inscrito
                  ? 'Solicitada com sucesso'
                  : 'Nao inscrita',
              'Erro inscricao Firebase':
                  resultadoAtual.erroInscricao ?? 'Nenhum erro capturado',
              'Inscricao backend':
                  inscricaoBackend?.inscrito == true ? 'Sim' : 'Nao',
              'Motivo backend':
                  inscricaoBackend?.motivo ?? 'Nenhum motivo informado',
              'Erro backend': inscricaoBackend?.erro ?? 'Nenhum erro capturado',
            },
          ),
          const SizedBox(height: 16),
          _SecaoDebug(
            titulo: 'Usuario',
            itens: {
              'ID usuario': usuario.id.toString(),
              'ID celula': usuario.idCelula?.toString() ?? 'null',
              'ID regiao': usuario.idRegiao?.toString() ?? 'null',
            },
          ),
          const SizedBox(height: 16),
          _SecaoDebug(
            titulo: 'Celula e topico',
            itens: {
              'Celula X': celula.x?.toString() ?? 'null',
              'Celula Y': celula.y?.toString() ?? 'null',
              'Topico backend': celula.topico ?? 'null',
              'Topico usado no Firebase': resultadoAtual.inscricao.topico,
              'Topico inscrito pelo backend':
                  inscricaoBackend?.topico ?? 'null',
            },
          ),
          const SizedBox(height: 16),
          _SecaoDebug(
            titulo: 'Localizacao enviada',
            itens: {
              'Latitude': resultadoAtual.localizacao.latitude.toString(),
              'Longitude': resultadoAtual.localizacao.longitude.toString(),
              'Descricao': resultadoAtual.localizacao.descricao,
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/mapa'),
            child: const Text('Ir para o mapa'),
          ),
        ],
      ),
    );
  }
}

class _DebugPreferenciasPage extends StatefulWidget {
  const _DebugPreferenciasPage();

  @override
  State<_DebugPreferenciasPage> createState() => _DebugPreferenciasPageState();
}

class _DebugPreferenciasPageState extends State<_DebugPreferenciasPage> {
  final ServicoPreferenciasUsuario _preferencias = ServicoPreferenciasUsuario();
  late Future<PreferenciasUsuario> _preferenciasFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _preferenciasFuture = _preferencias.carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depuracao de notificacoes'),
      ),
      body: FutureBuilder<PreferenciasUsuario>(
        future: _preferenciasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SecaoDebug(
                    titulo: 'Erro',
                    itens: {
                      'Falha ao carregar preferencias': snapshot.error.toString(),
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(_carregar),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final preferencias = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SecaoDebug(
                titulo: 'Preferencias locais',
                itens: {
                  'Usuario configurado':
                      preferencias?.configurado == true ? 'Sim' : 'Nao',
                  'Topico salvo':
                      preferencias?.topicoFcm ?? 'Nenhum topico salvo',
                  'ID/MAC salvo':
                      preferencias?.idDispositivo ?? 'Nenhum ID salvo',
                },
              ),
              const SizedBox(height: 16),
              _SecaoDebug(
                titulo: 'Como usar',
                itens: {
                  'Modo atual':
                      'Esta tela foi aberta pelo menu, entao mostra dados salvos no aparelho.',
                  'Cadastro completo':
                      'Para ver ID do usuario, celula X/Y e topico do backend, refaca o primeiro cadastro pelo botao de localizacao.',
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/localizacao',
                ),
                child: const Text('Refazer cadastro de localizacao'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/mapa',
                ),
                child: const Text('Ir para o mapa'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SecaoDebug extends StatelessWidget {
  const _SecaoDebug({
    required this.titulo,
    required this.itens,
  });

  final String titulo;
  final Map<String, String> itens;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            for (final item in itens.entries) ...[
              Text(
                item.key,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              SelectableText(
                item.value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
