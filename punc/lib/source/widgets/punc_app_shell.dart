import 'package:flutter/material.dart';
import '../../nucleo/temas/appCores.dart';

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
    // Cores do tema da aplicação
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8),
          child: Image.asset('assets/imagens/icones/logo.png'),
        ),
        // actions: [
        //   IconButton(
        //     tooltip: 'Notificações',
        //     icon: const Icon(Icons.notifications_none),
        //     onPressed: () => Navigator.pushNamed(context, '/debug-notificacoes'),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(child: body),
          // Barra Inferior com Navegação Funcional
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
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
                  colorScheme.onPrimary,
                ),
                _buildBottomNavItem(
                  context,
                  Icons.calendar_today,
                  'Cronograma',
                  selectedRoute == '/cronograma',
                  '/cronograma',
                  colorScheme.onPrimary,
                ),
                // _buildBottomNavItem(
                //   context,
                //   Icons.local_shipping_outlined,
                //   'Gerenciamento',
                //   selectedRoute == '/gerenciamento',
                //   '/gerenciamento',
                //   colorScheme.onPrimary,
                // ),
                _buildBottomNavItem(
                  context,
                  Icons.settings_outlined,
                  'Configurações',
                  selectedRoute == '/configuracoes',
                  '/configuracoes',
                  colorScheme.onPrimary,
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
    Color baseColor,
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
          Icon(icon, color: isSelected ? baseColor : baseColor.withOpacity(0.6), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? baseColor : baseColor.withOpacity(0.6),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
