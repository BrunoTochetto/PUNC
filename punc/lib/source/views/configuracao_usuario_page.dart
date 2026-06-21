import 'package:flutter/material.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
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
    const Color corFundoPagina = Color(0xFFD3E4D8);
    const Color corBotaoPrimario = Color(0xFF5E996E);

    return PuncAppShell(
      selectedRoute: '/configuracoes',
      body: Container(
        color: corFundoPagina,
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
              corBotao: corBotaoPrimario,
            );
          },
        ),
      ),
    );
  }
}

class _ConfiguracaoConteudo extends StatelessWidget {
  const _ConfiguracaoConteudo({
    required this.preferencias,
    required this.corBotao,
  });

  final PreferenciasUsuario preferencias;
  final Color corBotao;

  @override
  Widget build(BuildContext context) {
    const Color corTextoEscuro = Color(0xFF2C2C2C);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: corTextoEscuro,
            ),
          ),
          const SizedBox(height: 22),

          // Bloco de Informações do Dispositivo
          _buildContainer(
            context,
            child: Column(
              children: [
                const SectionHeader(
                  icon: Icons.devices_outlined,
                  title: 'Informações do dispositivo',
                ),
                _buildInfoRow('ID/MAC do dispositivo', preferencias.idDispositivo ?? 'Não configurado'),
                _buildInfoRow('Tópico FCM', preferencias.topicoFcm ?? 'Não configurado'),
                _buildInfoRow('Status', preferencias.configurado ? 'Configurado' : 'Não configurado'),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Bloco de Notificações
          _buildContainer(
            context,
            child: Column(
              children: [
                SectionHeader(
                  icon: Icons.notifications_none,
                  title: 'Notificações',
                ),
                SettingSwitch(
                  title: 'Receber notificações.',
                  value: true,
                  onChanged: (value) {},
                ),
                SettingSwitch(
                  title: 'Notificações das rotas.',
                  value: true,
                  onChanged: (value) {},
                ),
                SettingSwitch(
                  title: 'Notificações de atualizações de status.',
                  value: true,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/debug-notificacoes',
                    ),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Abrir depuração de notificações'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
