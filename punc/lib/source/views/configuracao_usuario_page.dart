import 'package:flutter/material.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_switch.dart';
import '../widgets/setting_text_field.dart';
import '../widgets/setting_dropdown.dart';

class ConfiguracaoUsuarioPage extends StatelessWidget {
  const ConfiguracaoUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6A64),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.eco, color: Colors.white, size: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configurações do usuário',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3E3A),
                    ),
                  ),
                  const Text(
                    'Gerencie suas preferências e informações da conta.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Seção Notificações
                  const SectionHeader(
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
                  const SizedBox(height: 24),

                  // Seção Identificação de usuário
                  const SectionHeader(
                    icon: Icons.person_outline,
                    title: 'Identificação de usuário',
                  ),
                  const SettingTextField(
                    label: 'Email',
                    initialValue: 'nicolyquechini6@gmail.com',
                    suffixIcon: Icons.mail_outline,
                  ),
                  const SettingTextField(
                    label: 'Telefone',
                    initialValue: '(49) 93485934869',
                    suffixIcon: Icons.phone_android,
                  ),
                  const SizedBox(height: 24),

                  // Seção Preferências
                  const SectionHeader(
                    icon: Icons.edit_note,
                    title: 'Preferências',
                  ),
                  const SettingSwitch(
                    title: 'Modo escuro',
                    value: false,
                    onChanged: null,
                  ),
                  const SettingDropdown(
                    label: 'Idioma',
                    value: 'Português',
                  ),
                ],
              ),
            ),
          ),
          
          // Botões de Ação Inferiores
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6A64),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
