import 'package:flutter/material.dart';
import 'package:punc/nucleo/temas/appCores.dart';
import '../widgets/card_grupo_regiao.dart';
import '../widgets/card_info_mapa.dart';
import '../widgets/barra_busca_mapa.dart';
import '../widgets/pin_mapa.dart';

class MapaGruposPage extends StatelessWidget {
  const MapaGruposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUNCCores.claroSuperficie,
      appBar: AppBar(
        backgroundColor: PUNCCores.claroAppBar,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: PUNCCores.claroOnAppBar, size: 24),
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
      body: Row(
        children: [
          // Área do Mapa
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Simulação do Mapa (Imagem de fundo ou Container colorido)
                Container(
                  color: const Color(0xFFDFF1E8),
                  child: Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Icon(Icons.map, size: 300, color: Colors.white),
                    ),
                  ),
                ),
                
                // Pins no Mapa
                const PinMapa(cor: Colors.blue, top: 150, left: 80),
                const PinMapa(cor: Colors.green, top: 120, left: 180),
                const PinMapa(cor: Colors.brown, top: 140, left: 280),
                const PinMapa(cor: Colors.black54, top: 200, left: 170),
                const PinMapa(cor: Colors.lightGreen, top: 300, left: 90),

                // Card Superior
                const Positioned(
                  top: 20,
                  left: 10,
                  right: 10,
                  child: CardInfoMapa(
                    titulo: 'Grupos da Região',
                    subtitulo: 'Veja no mapa a localização dos grupos de coleta da sua região',
                  ),
                ),

                // Barra de Busca Inferior
                const Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: BarraBuscaMapa(),
                ),
              ],
            ),
          ),

          // Lista Lateral de Grupos
          Container(
            width: 140,
            color: Colors.white.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grupos da Região',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      CardGrupoRegiao(
                        nome: 'Recicla Norte',
                        tipo: 'Coleta Seletiva',
                        local: 'Industrial',
                        distancia: '2,5 km de você',
                        corBorda: PUNCCores.escuroPrimaria,
                      ),
                      CardGrupoRegiao(
                        nome: 'Eco Centro',
                        tipo: 'Coleta Seletiva',
                        local: 'Centro',
                        distancia: '1,5 km de você',
                        corBorda: PUNCCores.escuroPrimaria,
                      ),
                      CardGrupoRegiao(
                        nome: 'Orgânicos Sul',
                        tipo: 'Resíduos Orgânicos',
                        local: 'Universitário',
                        distancia: '3,1 km de você',
                        corBorda: PUNCCores.escuroPrimaria,
                      ),
                      CardGrupoRegiao(
                        nome: 'Verde Vida',
                        tipo: 'Coleta Seletiva',
                        local: 'Bela Vista',
                        distancia: '2,8 km de você',
                        corBorda: PUNCCores.escuroPrimaria,
                      ),
                      CardGrupoRegiao(
                        nome: 'Linha Limpa',
                        tipo: 'Coleta Seletiva',
                        local: 'Linha Barra Fria',
                        distancia: '4,2 km de você',
                        corBorda: PUNCCores.escuroPrimaria,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('VER LISTA COMPLETA', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PUNCCores.escuroPrimaria,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: PUNCCores.claroAppBar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.map_outlined, 'Mapa', true),
            _buildNavItem(Icons.groups_outlined, 'Grupos', false),
            _buildNavItem(Icons.calendar_today_outlined, 'Cronograma', false),
            _buildNavItem(Icons.person_outline, 'Perfil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
