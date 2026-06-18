import 'package:flutter/material.dart';
import 'package:punc/nucleo/temas/appCores.dart';
import '../data/modelos/perfil_usuario.dart';
import '../viewmodels/perfil_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_dropdown.dart';
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
                  'Configurações do usuário',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: corTextoEscuro,
                  ),
                ),
                Text(
                  'Gerencie suas preferências e informações da conta.',
                  style: TextStyle(
                    color: corTextoEscuro.withOpacity(0.7),
                    fontSize: 14,
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
                      const SettingSwitch(
                        title: 'Receber notificações.',
                        value: true,
                        onChanged: null,
                      ),
                      const SettingSwitch(
                        title: 'Notificações das rotas.',
                        value: true,
                        onChanged: null,
                      ),
                      const SettingSwitch(
                        title: 'Notificações de atualizações de status.',
                        value: true,
                        onChanged: null,
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
                          label: const Text('Abrir debug de notificacoes'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 22),
                
                // Bloco de Identificação
                _buildContainer(
                  context,
                  child: Column(
                    children: [
                      const SectionHeader(
                        icon: Icons.person_outline,
                        title: 'Identificação de usuário',
                      ),
                      SettingTextField(
                        label: 'Email',
                        initialValue: perfil.email,
                        suffixIcon: Icons.mail_outline,
                      ),
                      SettingTextField(
                        label: 'Telefone',
                        initialValue: perfil.telefone,
                        suffixIcon: Icons.phone_android,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 22),
                
                // Bloco de Preferências
                _buildContainer(
                  context,
                  child: Column(
                    children: [
                      const SectionHeader(
                        icon: Icons.edit_note,
                        title: 'Preferências',
                      ),
                      SettingSwitch(
                        title: 'Modo escuro',
                        value: perfil.modoEscuro,
                        onChanged: null,
                      ),
                      SettingDropdown(
                        label: 'Idioma',
                        value: perfil.idioma,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Rodapé com Botões - Branco Puro e Borda
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: corBordaCinza)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: corBordaCinza),
                    foregroundColor: corTextoEscuro,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corBotao,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Salvar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
