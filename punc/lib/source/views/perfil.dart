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
    // Identidade Visual: Tons Pastéis, Branco Puro e Bordas Cinzas
    const Color corFundoPagina = Color(0xFFD3E4D8); // Verde pastel suave do fundo
    const Color corBotaoPrimario = Color(0xFF5E996E); // Verde folha suave (Botões)

    return PuncAppShell(
      selectedRoute: '/perfil',
      body: Container(
        color: corFundoPagina, // Aplicando fundo pastel
        child: FutureBuilder<PerfilUsuario?>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EstadoCarregando();
            }

            if (snapshot.hasError) {
              return EstadoErro(
                mensagem: 'Não foi possível carregar o perfil.',
                onTentarNovamente: () => setState(_carregar),
              );
            }

            final perfil = snapshot.data;
            if (perfil == null) {
              return const EstadoVazio(mensagem: 'Perfil não encontrado.');
            }

            return _PerfilConteudo(
              perfil: perfil,
              corBotao: corBotaoPrimario,
            );
          },
        ),
      ),
    );
  }
}

class _PerfilConteudo extends StatelessWidget {
  const _PerfilConteudo({
    required this.perfil,
    required this.corBotao,
  });

  final PerfilUsuario perfil;
  final Color corBotao;

  @override
  Widget build(BuildContext context) {
    const Color corTextoEscuro = Color(0xFF2C2C2C);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar estilizado
          CircleAvatar(
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
          const SizedBox(height: 34),
          // Os widgets CardPerfil devem ser atualizados internamente para Branco Puro e Borda Cinza
          CardPerfil(
            icon: Icons.person_outline,
            title: 'Informações pessoais',
            details: [
              {'Nome': perfil.nome},
              {'Email': perfil.email},
              {'Telefone': perfil.telefone},
            ],
          ),
          const SizedBox(height: 16),
          CardPerfil(
            icon: Icons.edit_note,
            title: 'Preferências',
            details: [
              {'Modo escuro': perfil.modoEscuro ? 'Ativado' : 'Desativado'},
              {'Idioma': perfil.idioma},
              {
                'Notificação por email':
                    perfil.notificacaoEmail ? 'Ativado' : 'Desativado',
              },
            ],
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: corBotao,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Editar perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
