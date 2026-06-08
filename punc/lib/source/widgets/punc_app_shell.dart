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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
          child: Image.asset('assets/imagens/icones/logo.png'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notificacoes',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Configuracoes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
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
            ],
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(child: body),
          Container(
            height: 72,
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
        ],
      ),
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
    return ListTile(
      selected: selectedRoute == route,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (selectedRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
