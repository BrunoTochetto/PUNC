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
            tooltip: 'Notificacoes',
            icon: const Icon(Icons.notifications_none, color: corIconeAppBar),
            onPressed: () => Navigator.pushNamed(context, '/debug-notificacoes'),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            icon: const Icon(Icons.settings_outlined, color: corIconeAppBar),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu, color: corIconeAppBar),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: ListView(
            children: [
              _MenuItem(
                route: '/mapa',
                selectedRoute: selectedRoute,
                icon: Icons.map_outlined,
                label: 'Mapa',
              ),
              _MenuItem(
                route: '/cronograma',
                selectedRoute: selectedRoute,
                icon: Icons.calendar_today_outlined,
                label: 'Cronograma',
              ),
              _MenuItem(
                route: '/gerenciamento',
                selectedRoute: selectedRoute,
                icon: Icons.local_shipping_outlined,
                label: 'Gerenciamento',
              ),
              _MenuItem(
                route: '/perfil',
                selectedRoute: selectedRoute,
                icon: Icons.person_outline,
                label: 'Perfil',
              ),
              _MenuItem(
                route: '/debug-notificacoes',
                selectedRoute: selectedRoute,
                icon: Icons.bug_report_outlined,
                label: 'Debug notificacoes',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(child: body),
          // Barra Inferior (Simulando a BottomNavigationBar do design)
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
                _buildBottomNavItem(Icons.map_outlined, 'Mapa', selectedRoute == '/mapa'),
                _buildBottomNavItem(Icons.groups_outlined, 'Grupos', selectedRoute == '/grupos'),
                _buildBottomNavItem(Icons.calendar_today, 'Cronograma', selectedRoute == '/cronograma'),
                _buildBottomNavItem(Icons.person_outline, 'Perfil', selectedRoute == '/perfil'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.route,
    required this.selectedRoute,
    required this.icon,
    required this.label,
  });

  final String route;
  final String? selectedRoute;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedRoute == route;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFFD3E4D8),
      leading: Icon(icon, color: isSelected ? const Color(0xFF5E996E) : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF2C2C2C) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (selectedRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
