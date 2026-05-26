import 'package:flutter/material.dart';
import '/nucleo/temas/appCores.dart';
import '/source/widgets/card_info_perfil.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUNCCores.claroSuperficie,
      appBar: AppBar(
        backgroundColor: PUNCCores.claroAppBar,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.eco, color: PUNCCores.claroOnAppBar, size: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: PUNCCores.claroOnAppBar),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: PUNCCores.claroOnAppBar),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.menu, color: PUNCCores.claroOnAppBar),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar do Perfil
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card Informações Pessoais
                  const CardInfoPerfil(
                    icon: Icons.person_outline,
                    title: 'Informações pessoais',
                    details: [
                      {'Nome': 'Nicoly Quechini'},
                      {'Email': 'nicolyquechini6@gmail.com'},
                      {'Telefone': '(49) 93485934869'},
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card Preferências
                  const CardInfoPerfil(
                    icon: Icons.edit_note,
                    title: 'Preferências',
                    details: [
                      {'Modo escuro': 'Desativado'},
                      {'Idioma': 'Português'},
                      {'Notificação por email': 'Ativado'},
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Botão Editar Perfil
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PUNCCores.claroAppBar,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Editar perfil',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Rodapé
          Container(
            height: 60,
            color: PUNCCores.claroAppBar,
          ),
        ],
      ),
    );
  }
}
