import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../viewmodels/configuracao_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_switch.dart';

class ConfiguracaoUsuarioPage extends StatefulWidget {
  const ConfiguracaoUsuarioPage({super.key});

  @override
  State<ConfiguracaoUsuarioPage> createState() =>
      _ConfiguracaoUsuarioPageState();
}

class _ConfiguracaoUsuarioPageState extends State<ConfiguracaoUsuarioPage> {
  final ServicoPreferenciasUsuario _servicoPreferencias =
      ServicoPreferenciasUsuario();
  late Future<PreferenciasUsuario> _preferenciasFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _preferenciasFuture = _servicoPreferencias.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PuncAppShell(
      selectedRoute: '/configuracoes',
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: FutureBuilder<PreferenciasUsuario>(
          future: _preferenciasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EstadoCarregando();
            }

            if (snapshot.hasError) {
              return EstadoErro(
                mensagem: 'Não foi possível carregar as configurações.',
                onTentarNovamente: () => setState(_carregar),
              );
            }

            final preferencias = snapshot.data;
            if (preferencias == null) {
              return const EstadoVazio(
                mensagem: 'Configurações não encontradas.',
              );
            }

            return _ConfiguracaoConteudo(
              preferencias: preferencias,
              colorScheme: colorScheme,
              servicoPreferencias: _servicoPreferencias,
              onAtualizar: () => setState(_carregar),
            );
          },
        ),
      ),
    );
  }
}

class _ConfiguracaoConteudo extends StatefulWidget {
  const _ConfiguracaoConteudo({
    required this.preferencias,
    required this.colorScheme,
    required this.servicoPreferencias,
    required this.onAtualizar,
  });

  final PreferenciasUsuario preferencias;
  final ColorScheme colorScheme;
  final ServicoPreferenciasUsuario servicoPreferencias;
  final VoidCallback onAtualizar;

  @override
  State<_ConfiguracaoConteudo> createState() => _ConfiguracaoConteudoState();
}

class _ConfiguracaoConteudoState extends State<_ConfiguracaoConteudo> {
  final ConfiguracaoViewModel _viewModel = ConfiguracaoViewModel();
  bool _reiniciando = false;

  PreferenciasUsuario get preferencias => widget.preferencias;
  ColorScheme get colorScheme => widget.colorScheme;

  bool get _podeReiniciarTopico =>
      preferencias.configurado && (preferencias.topicoFcm?.isNotEmpty ?? false);

  Future<void> _mudarCep() async {
    final novoCep = await showDialog<String>(
      context: context,
      builder: (context) => _DialogMudarCep(cepInicial: preferencias.cep ?? ''),
    );

    if (novoCep == null || !mounted) return;

    await widget.servicoPreferencias.salvarCep(novoCep);
    widget.onAtualizar();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CEP atualizado com sucesso.')),
    );
  }

  Future<void> _reiniciarTopico() async {
    await _executarReinicio(_viewModel.reiniciarTopicoFcm);
  }

  Future<void> _reiniciarAmbos() async {
    await _executarReinicio(_viewModel.reiniciarAmbos);
  }

  Future<void> _executarReinicio(
    Future<ResultadoReinicio> Function() acao,
  ) async {
    setState(() => _reiniciando = true);
    try {
      final resultado = await acao();
      if (!mounted) return;

      widget.onAtualizar();

      if (resultado.mensagem != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensagem!)),
        );
      }
    } finally {
      if (mounted) setState(() => _reiniciando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 22),

          _buildContainer(
            context,
            child: Column(
              children: [
                const SectionHeader(
                  icon: Icons.devices_outlined,
                  title: 'Informações do dispositivo',
                ),
                _buildInfoRow(
                  'ID/MAC do dispositivo',
                  preferencias.idDispositivo ?? 'Não configurado',
                  context,
                ),
                _buildInfoRow(
                  'Status',
                  preferencias.configurado ? 'Configurado' : 'Não configurado',
                  context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          _buildContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  icon: Icons.location_on_outlined,
                  title: 'Localização e notificações',
                ),
                _buildInfoRow(
                  'CEP',
                  preferencias.cep ?? 'Não informado',
                  context,
                  trailing: TextButton(
                    onPressed: _reiniciando ? null : _mudarCep,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Mudar'),
                  ),
                ),
                _buildInfoRow(
                  'Tópico FCM',
                  preferencias.topicoFcm ?? 'Não configurado',
                  context,
                ),
                const Divider(height: 24),
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _reiniciando || !_podeReiniciarTopico
                          ? null
                          : _reiniciarTopico,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reiniciar tópico'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (_reiniciando)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                if (!_podeReiniciarTopico)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Configure a localização no primeiro acesso para reiniciar o tópico.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // _buildContainer(
          //   context,
          //   child: Column(
          //     children: [
          //       SectionHeader(
          //         icon: Icons.notifications_none,
          //         title: 'Notificações',
          //       ),
          //       SettingSwitch(
          //         title: 'Receber notificações.',
          //         value: true,
          //         onChanged: (value) {},
          //       ),
          //       SettingSwitch(
          //         title: 'Notificações das rotas.',
          //         value: true,
          //         onChanged: (value) {},
          //       ),
          //       SettingSwitch(
          //         title: 'Notificações de atualizações de status.',
          //         value: true,
          //         onChanged: (value) {},
          //       ),
          //       const SizedBox(height: 12),
          //       if (kDebugMode)
          //         SizedBox(
          //           width: double.infinity,
          //           child: OutlinedButton.icon(
          //             onPressed: () => Navigator.pushNamed(
          //               context,
          //               '/debug-notificacoes',
          //             ),
          //             icon: const Icon(Icons.bug_report_outlined),
          //             label: const Text('Abrir depuração de notificações'),
          //           ),
          //         ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surface),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DialogMudarCep extends StatefulWidget {
  const _DialogMudarCep({required this.cepInicial});

  final String cepInicial;

  @override
  State<_DialogMudarCep> createState() => _DialogMudarCepState();
}

class _DialogMudarCepState extends State<_DialogMudarCep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.cepInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _salvar() {
    final cep = _controller.text.trim();
    if (cep.isEmpty) return;
    Navigator.pop(context, cep);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mudar CEP'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        maxLength: 9,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Digite seu CEP',
          prefixIcon: Icon(Icons.local_post_office_outlined),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
