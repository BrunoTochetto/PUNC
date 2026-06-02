import 'package:flutter/material.dart';
import '../widgets/card_veiculo.dart';

class GerenciamentoPage extends StatefulWidget {
  const GerenciamentoPage({super.key});

  @override
  State<GerenciamentoPage> createState() => _GerenciamentoPageState();
}

class _GerenciamentoPageState extends State<GerenciamentoPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.eco, color: Colors.white, size: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gerenciamento',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Motoristas e Caminhões',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Adicionar motorista/caminhão'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ), // Cor semântica mantida
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar agrupador',
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CardVeiculo(
                    title: 'Caminhão 01',
                    driver: 'Motorista Nicoly Quaichum',
                    plate: 'Placa BTS-525',
                    phone: '(49) 99918-2387',
                    status: 'Em rota',
                    statusColor: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  const CardVeiculo(
                    title: 'Caminhão 01',
                    driver: 'Motorista Nicoly Quaichum',
                    plate: 'Placa ABC-123',
                    phone: '(49) 99918-2387',
                    status: 'Disponível',
                    statusColor: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.list, size: 20),
                      label: const Text('Ver todos os veículos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 60, color: theme.appBarTheme.backgroundColor),
        ],
      ),
    );
  }
}
