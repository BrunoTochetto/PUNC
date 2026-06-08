import 'package:flutter/material.dart';

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
    return PuncAppShell(
      selectedRoute: '/configuracoes',
      body: FutureBuilder<PerfilUsuario?>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarregando();
          }

          if (snapshot.hasError) {
            return EstadoErro(
              mensagem: 'Nao foi possivel carregar as configuracoes.',
              onTentarNovamente: () => setState(_carregar),
            );
          }

          final perfil = snapshot.data;
          if (perfil == null) {
            return const EstadoVazio(
              mensagem: 'Configuracoes nao encontradas.',
            );
          }

          return _ConfiguracaoConteudo(perfil: perfil);
        },
      ),
    );
  }
}

class _ConfiguracaoConteudo extends StatelessWidget {
  const _ConfiguracaoConteudo({required this.perfil});

  final PerfilUsuario perfil;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuracoes do usuario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Text('Gerencie suas preferencias e informacoes da conta.'),
                const SizedBox(height: 22),
                const SectionHeader(
                  icon: Icons.notifications_none,
                  title: 'Notificacoes',
                ),
                const SettingSwitch(
                  title: 'Receber notificacoes.',
                  value: true,
                  onChanged: null,
                ),
                const SettingSwitch(
                  title: 'Notificacoes das rotas.',
                  value: true,
                  onChanged: null,
                ),
                const SettingSwitch(
                  title: 'Notificacoes de atualizacoes de status.',
                  value: true,
                  onChanged: null,
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Identificacao de usuario',
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
                const SizedBox(height: 22),
                const SectionHeader(
                  icon: Icons.edit_note,
                  title: 'Preferencias',
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
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Salvar Alteracoes'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
