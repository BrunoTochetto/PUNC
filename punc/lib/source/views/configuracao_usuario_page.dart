import 'package:flutter/material.dart';
import 'package:punc/nucleo/temas/appCores.dart';
import '../data/modelos/perfil_usuario.dart';
import '../viewmodels/perfil_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_switch.dart';
import '../widgets/setting_text_field.dart';

class ConfiguracaoUsuarioPage extends StatefulWidget {
  const ConfiguracaoUsuarioPage({super.key});

  @override
  State<ConfiguracaoUsuarioPage> createState() =>
      _ConfiguracaoUsuarioPageState();
}

class _ConfiguracaoUsuarioPageState extends State<ConfiguracaoUsuarioPage> {
  final PerfilViewModel _viewModel = PerfilViewModel();
  late Future<PerfilUsuario?> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _perfilFuture = _viewModel.carregarPerfil();
  }

  @override
  Widget build(BuildContext context) {
    // Identidade Visual: Tons Pastéis, Branco Puro e Bordas Cinzas
    const Color corFundoPagina = Color(0xFFD3E4D8); // Verde pastel suave do fundo
    const Color corBotaoPrimario = Color(0xFF5E996E); // Verde folha suave

    return PuncAppShell(
      selectedRoute: '/configuracoes',
      body: Container(
        color: corFundoPagina,
        child: FutureBuilder<PerfilUsuario?>(
          future: _perfilFuture,
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

            final perfil = snapshot.data;
            if (perfil == null) {
              return const EstadoVazio(
                mensagem: 'Configurações não encontradas.',
              );
            }

            return _ConfiguracaoConteudo(
              perfil: perfil,
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
    required this.perfil,
    required this.corBotao,
  });

  final PerfilUsuario perfil;
  final Color corBotao;

  @override
  Widget build(BuildContext context) {
    const Color corTextoEscuro = Color(0xFF2C2C2C);
    const Color corBordaCinza = Color(0xFFE0E0E0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu Perfil',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: corTextoEscuro,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 54,
                          color: corBotao.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 34),

                // Bloco de Informações Pessoais
                _buildContainer(
                  context,
                  child: Column(
                    children: [
                      const SectionHeader(
                        icon: Icons.person_outline,
                        title: 'Informações pessoais',
                      ),
                      SettingTextField(
                        label: 'Nome',
                        initialValue: '',
                        suffixIcon: Icons.person_outline,
                      ),
                      SettingTextField(
                        label: 'Email',
                        initialValue: '',
                        suffixIcon: Icons.mail_outline,
                      ),
                      SettingTextField(
                        label: 'Telefone',
                        initialValue: '',
                        suffixIcon: Icons.phone_android,
                      ),
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

                const SizedBox(height: 22),

                // Bloco de Identificação Adicional
                _buildContainer(
                  context,
                  child: Column(
                    children: [
                      const SectionHeader(
                        icon: Icons.settings_outlined,
                        title: 'Configurações adicionais',
                      ),
                      SettingSwitch(
                        title: 'Notificação por email',
                        value: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Corrigido: Branco Puro e Borda Cinza
  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Branco Puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)), // Borda Cinza Clara
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
