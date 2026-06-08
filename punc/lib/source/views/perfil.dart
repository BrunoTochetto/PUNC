import 'package:flutter/material.dart';

import '../data/modelos/perfil_usuario.dart';
import '../viewmodels/perfil_view_model.dart';
import '../widgets/card_perfil.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
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
      selectedRoute: '/perfil',
      body: FutureBuilder<PerfilUsuario?>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarregando();
          }

          if (snapshot.hasError) {
            return EstadoErro(
              mensagem: 'Nao foi possivel carregar o perfil.',
              onTentarNovamente: () => setState(_carregar),
            );
          }

          final perfil = snapshot.data;
          if (perfil == null) {
            return const EstadoVazio(mensagem: 'Perfil nao encontrado.');
          }

          return _PerfilConteudo(perfil: perfil);
        },
      ),
    );
  }
}

class _PerfilConteudo extends StatelessWidget {
  const _PerfilConteudo({required this.perfil});

  final PerfilUsuario perfil;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 46,
            backgroundColor: Colors.black.withOpacity(0.08),
            child: Icon(
              Icons.person,
              size: 54,
              color: Colors.black.withOpacity(0.18),
            ),
          ),
          const SizedBox(height: 34),
          CardPerfil(
            icon: Icons.person_outline,
            title: 'Informacoes pessoais',
            details: [
              {'Nome': perfil.nome},
              {'Email': perfil.email},
              {'Telefone': perfil.telefone},
            ],
          ),
          const SizedBox(height: 16),
          CardPerfil(
            icon: Icons.edit_note,
            title: 'Preferencias',
            details: [
              {'Modo escuro': perfil.modoEscuro ? 'Ativado' : 'Desativado'},
              {'Idioma': perfil.idioma},
              {
                'Notificacao por email':
                    perfil.notificacaoEmail ? 'Ativado' : 'Desativado',
              },
            ],
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
              child: const Text('Editar perfil'),
            ),
          ),
        ],
      ),
    );
  }
}
