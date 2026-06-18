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
    // Cores ajustadas para serem mais claras e vibrantes (Identidade PUNC)
    const Color corFundoPagina = Color(0xFFF8F9FA); // Cinza quase branco, bem limpo
    const Color corAppBar = Color(0xFF5BA7B4);      // Verde água/Teal vibrante do Figma
    const Color corBotaoPrimario = Color(0xFF5E9A78); // Verde folha/saúde do Figma
    const Color corCardBranco = Colors.white; 
    const Color corTextoEscuro = Color(0xFF333333);

    return Scaffold(
      backgroundColor: corFundoPagina,
      appBar: AppBar(
        backgroundColor: corAppBar,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
            child: const Icon(Icons.eco, color: Colors.white, size: 20),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: corCardBranco,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: corBotaoPrimario.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 28, color: corBotaoPrimario),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adição de cronograma', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: corTextoEscuro)),
                      const SizedBox(height: 2),
                      Text('Preencha as informações para\nadicionar um cronograma de coleta', 
                        style: TextStyle(fontSize: 11, color: corTextoEscuro.withOpacity(0.6))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section (Left)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildStepItem('1', 'Selecione o grupo', _buildDropdown('Recicla Norte', Icons.groups_outlined, corBotaoPrimario), corBotaoPrimario),
                      _buildStepItem('2', 'Selecione o tipo de coleta', const SeletorTipoColeta(), corBotaoPrimario),
                      _buildStepItem('3', 'Selecione os dias da semana', const SeletorDiasSemana(), corBotaoPrimario),
                      _buildStepItem('4', 'Selecione o horário', 
                        Row(
                          children: [
                            Expanded(child: _buildTimePicker('Horário de início', '08:00', corBotaoPrimario)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTimePicker('Horário de término', '12:00', corBotaoPrimario)),
                          ],
                        ),
                        corBotaoPrimario,
                      ),
                      _buildStepItem('5', 'Defina a frequência', _buildDropdown('Semanal', Icons.sync, corBotaoPrimario), corBotaoPrimario),
                      _buildStepItem('6', 'Observações (opcional)', 
                        TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Adicione informações adicionais sobre o cronograma...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        corBotaoPrimario,
                        isLast: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Text('CANCELAR', 
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: corBotaoPrimario,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('SALVAR CRONOGRAMA', 
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Summary Section (Right)
                Expanded(
                  child: Column(
                    children: [
                      const CardResumoCronograma(),
                      const SizedBox(height: 20),
                      _buildAreaAtendimento(corBotaoPrimario),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: corAppBar,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.map_outlined, 'Mapa', false),
            _buildNavItem(Icons.groups_outlined, 'Grupos', false),
            _buildNavItem(Icons.calendar_today, 'Cronograma', true),
            _buildNavItem(Icons.person_outline, 'Perfil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, Widget content, Color accentColor, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(number, 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
                const SizedBox(height: 10),
                content,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String time, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: accentColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAreaAtendimento(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Área de atendimento', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF333333))),
                    Text('Visualização aproximada...', 
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.map, size: 70, color: accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), size: 24),
        const SizedBox(height: 4),
        Text(label, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), 
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
