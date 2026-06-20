import 'package:flutter/material.dart';

class PuncAppShell extends StatelessWidget {
  const PuncAppShell({
    super.key,
    required this.body,
    this.selectedRoute,
    this.floatingActionButton,
  });

  final Widget body;
  final String? selectedRoute;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // Cores Claras e Vibrantes (Identidade Figma)
    const Color corAppBar = Color(0xFF486062);      // Verde escuro acinzentado do Figma
    const Color corFundoPagina = Color(0xFFD3E4D8); // Verde pastel suave do fundo
    const Color corIconeAppBar = Colors.white;

    return Scaffold(
      backgroundColor: corFundoPagina, // Forçando o fundo claro/pastel
      appBar: AppBar(
        backgroundColor: corAppBar, // Forçando a cor correta da AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: corIconeAppBar),
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
          child: Image.asset('assets/imagens/icones/logo.png'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notificações',
            icon: const Icon(Icons.notifications_none, color: corIconeAppBar),
            onPressed: () => Navigator.pushNamed(context, '/debug-notificacoes'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(child: body),
          // Barra Inferior com Navegação Funcional
          Container(
            height: 72,
            decoration: const BoxDecoration(
              color: corAppBar, // Mesma cor da AppBar
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  context,
                  Icons.map_outlined,
                  'Mapa',
                  selectedRoute == '/mapa',
                  '/mapa',
                ),
                _buildBottomNavItem(
                  context,
                  Icons.calendar_today,
                  'Cronograma',
                  selectedRoute == '/cronograma',
                  '/cronograma',
                ),
                _buildBottomNavItem(
                  context,
                  Icons.local_shipping_outlined,
                  'Gerenciamento',
                  selectedRoute == '/gerenciamento',
                  '/gerenciamento',
                ),
                _buildBottomNavItem(
                  context,
                  Icons.settings_outlined,
                  'Configurações',
                  selectedRoute == '/configuracoes',
                  '/configuracoes',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        if (selectedRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
