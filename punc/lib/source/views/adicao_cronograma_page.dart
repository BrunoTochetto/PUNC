import 'package:flutter/material.dart';
import 'package:punc/nucleo/temas/appCores.dart';
import '../widgets/item_etapa_cronograma.dart';
import '../widgets/card_resumo_cronograma.dart';
import '../widgets/seletor_tipo_coleta.dart';
import '../widgets/seletor_dias_semana.dart';

class AdicaoCronogramaPage extends StatelessWidget {
  const AdicaoCronogramaPage({super.key});

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
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Icon(Icons.eco, color: PUNCCores.claroOnAppBar, size: 24),
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none, color: PUNCCores.claroOnAppBar), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings_outlined, color: PUNCCores.claroOnAppBar), onPressed: () {}),
          IconButton(icon: Icon(Icons.menu, color: PUNCCores.claroOnAppBar), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Adição de cronograma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Preencha as informações para\nadicionar um cronograma de coleta', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formulário (Esquerda)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ItemEtapaCronograma(
                        numero: '1',
                        titulo: 'Selecione o grupo',
                        conteudo: _buildDropdown('Recicla Norte', Icons.groups_outlined),
                      ),
                      const ItemEtapaCronograma(
                        numero: '2',
                        titulo: 'Selecione o tipo de coleta',
                        conteudo: SeletorTipoColeta(),
                      ),
                      const ItemEtapaCronograma(
                        numero: '3',
                        titulo: 'Selecione os dias da semana',
                        conteudo: SeletorDiasSemana(),
                      ),
                      ItemEtapaCronograma(
                        numero: '4',
                        titulo: 'Selecione o horário',
                        conteudo: Row(
                          children: [
                            Expanded(child: _buildTimePicker('Horário de início', '08:00')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTimePicker('Horário de término', '12:00')),
                          ],
                        ),
                      ),
                      ItemEtapaCronograma(
                        numero: '5',
                        titulo: 'Defina a frequência',
                        conteudo: _buildDropdown('Semanal', Icons.sync),
                      ),
                      ItemEtapaCronograma(
                        numero: '6',
                        titulo: 'Observações (opcional)',
                        mostrarLinha: false,
                        conteudo: TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Adicione informações adicionais sobre o cronograma...',
                            hintStyle: const TextStyle(fontSize: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text('CANCELAR', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PUNCCores.escuroPrimaria,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('SALVAR CRONOGRAMA', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Resumo (Direita)
                Expanded(
                  child: Column(
                    children: [
                      const CardResumoCronograma(),
                      const SizedBox(height: 16),
                      _buildAreaAtendimento(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: PUNCCores.claroAppBar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.map_outlined, 'Mapa', false),
            _buildNavItem(Icons.groups_outlined, 'Grupos', false),
            _buildNavItem(Icons.calendar_today_outlined, 'Cronograma', true),
            _buildNavItem(Icons.person_outline, 'Perfil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAreaAtendimento() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF1E8).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Área de atendimento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('Visualização aproximada...', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.2,
                child: Icon(Icons.map, size: 80, color: PUNCCores.escuroPrimaria),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected ? BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
