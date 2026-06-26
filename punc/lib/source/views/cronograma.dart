import 'package:flutter/material.dart';
import '../data/modelos/horario_coleta.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../viewmodels/cronograma_view_model.dart';
import '../widgets/card_crono.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

class CronogramaPage extends StatefulWidget {
  const CronogramaPage({super.key});

  @override
  State<CronogramaPage> createState() => _CronogramaPageState();
}

class _CronogramaPageState extends State<CronogramaPage> {
  final CronogramaViewModel _viewModel = CronogramaViewModel();
  final ServicoPreferenciasUsuario _preferencias = ServicoPreferenciasUsuario();
  final TextEditingController _cepController = TextEditingController();

  List<HorarioColeta> _horarios = [];
  String _cepAtual = '';
  String? _mensagemErro;
  bool _carregandoInicial = true;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    final prefs = await _preferencias.carregar();
    final cepSalvo = prefs.cep?.trim() ?? '';

    if (cepSalvo.isNotEmpty) {
      _cepController.text = cepSalvo;

      final cache = await _viewModel.carregarSomenteCache(cep: cepSalvo);
      if (!mounted) return;
      setState(() {
        _horarios = cache.horarios;
        _cepAtual = cache.cep;
        _carregandoInicial = false;
        _buscando = true;
      });

      final resultado = await _viewModel.buscarNaRede(cep: cepSalvo);
      if (!mounted) return;
      setState(() {
        _horarios = resultado.horarios;
        _cepAtual = resultado.cep;
        _mensagemErro = resultado.mensagemErro;
        _buscando = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _carregandoInicial = false);
    }
  }

  Future<void> _buscarPorCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um CEP para buscar.')),
      );
      return;
    }

    setState(() {
      _buscando = true;
      _mensagemErro = null;
    });

    await _preferencias.salvarCep(cep);

    final resultado = await _viewModel.buscarNaRede(cep: cep);
    if (!mounted) return;

    setState(() {
      _horarios = resultado.horarios;
      _cepAtual = resultado.cep;
      _mensagemErro = resultado.mensagemErro;
      _buscando = false;
    });

    if (resultado.mensagemErro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.mensagemErro!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PuncAppShell(
      selectedRoute: '/cronograma',
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: _construirConteudo(colorScheme),
      ),
    );
  }

  Widget _construirConteudo(ColorScheme colorScheme) {
    if (_carregandoInicial) {
      return const EstadoCarregando();
    }

    if (_horarios.isEmpty) {
      return _EstadoVazioComCep(
        cepController: _cepController,
        carregando: _buscando,
        cepAtual: _cepAtual,
        mensagemErro: _mensagemErro,
        onBuscar: _buscarPorCep,
      );
    }

    return _CronogramaConteudo(
      horarios: _horarios,
      corTexto: colorScheme.onSurface,
      cepAtual: _cepAtual,
      buscando: _buscando,
      onBuscarOutroCep: () => setState(() => _horarios = []),
    );
  }
}

class _EstadoVazioComCep extends StatelessWidget {
  const _EstadoVazioComCep({
    required this.cepController,
    required this.carregando,
    required this.cepAtual,
    required this.onBuscar,
    this.mensagemErro,
  });

  final TextEditingController cepController;
  final bool carregando;
  final String cepAtual;
  final String? mensagemErro;
  final VoidCallback onBuscar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              cepAtual.isEmpty
                  ? 'Informe seu CEP para ver os horarios de coleta.'
                  : 'Nenhum horario de coleta encontrado para o CEP $cepAtual.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (mensagemErro != null) ...[
              const SizedBox(height: 8),
              Text(
                mensagemErro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: cepController,
              enabled: !carregando,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: const InputDecoration(
                hintText: 'Digite seu CEP',
                prefixIcon: Icon(Icons.local_post_office_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: carregando ? null : onBuscar,
                child: carregando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Buscar horarios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CronogramaConteudo extends StatelessWidget {
  const _CronogramaConteudo({
    required this.horarios,
    required this.corTexto,
    required this.cepAtual,
    required this.buscando,
    required this.onBuscarOutroCep,
  });

  final List<HorarioColeta> horarios;
  final Color corTexto;
  final String cepAtual;
  final bool buscando;
  final VoidCallback onBuscarOutroCep;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cronograma de coleta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corTexto,
                      ),
                    ),
                    if (cepAtual.isNotEmpty)
                      Text(
                        'CEP $cepAtual',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (buscando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          ...horarios.map(
            (horario) => CardCrono(
              day: horario.diaSemana,
              time: horario.horarioEstimado,
              type: horario.tipoLixo,
              iconColor: _corTipo(horario.tipoLixo),
              onTap: () => _mostrarComentarios(context, horario),
            ),
          ),
        ],
      ),
    );
  }

  Color _corTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado.contains('organ') || normalizado.contains('orgân')) {
      return const Color(0xFF8B4513);
    }
    return const Color(0xFF4AA564);
  }

  void _mostrarComentarios(BuildContext context, HorarioColeta horario) {
    final comentarios = horario.comentarios?.trim();
    final textoComentarios = comentarios != null && comentarios.isNotEmpty
        ? comentarios
        : 'Nenhum comentario para este horario.';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(horario.diaSemana),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Horario: ${horario.horarioEstimado}'),
              Text('Tipo: ${horario.tipoLixo}'),
              const SizedBox(height: 12),
              Text(
                'Comentarios',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(textoComentarios),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

