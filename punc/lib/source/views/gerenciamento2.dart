import 'package:flutter/material.dart';
import '../data/modelos/gerente.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../domain/casodeuso/gerente/cadastrar_motorista.dart';
import '../widgets/punc_app_shell.dart';
import '../widgets/section_header.dart';

class Gerenciamento2Page extends StatefulWidget {
  const Gerenciamento2Page({super.key});

  @override
  State<Gerenciamento2Page> createState() => _Gerenciamento2PageState();
}

class _Gerenciamento2PageState extends State<Gerenciamento2Page> {
  static const int _idGerentePadrao = 1;

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _numeroController = TextEditingController();
  final _placaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _casodeUso = CadastrarMotorista();
  final _servicoPreferencias = ServicoPreferenciasUsuario();

  String _selectedStatus = 'Disponível';
  bool _salvando = false;
  bool _carregandoMac = true;

  @override
  void initState() {
    super.initState();
    _carregarMacDispositivo();
  }

  Future<void> _carregarMacDispositivo() async {
    final identificacao =
        await _servicoPreferencias.obterIdentificacaoDispositivo();
    if (!mounted) return;
    setState(() {
      _numeroController.text = identificacao.mac;
      _carregandoMac = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _numeroController.dispose();
    _placaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty ||
        _numeroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await _casodeUso.executar(
        idGerente: _idGerentePadrao,
        nomeDispositivo: _nomeController.text.trim(),
        mac: _numeroController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motorista/caminhão salvo com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color corFundoPagina = Color(0xFFD3E4D8);
    const Color corBotaoPrimario = Color(0xFF5E996E);
    const Color corTextoEscuro = Color(0xFF2C2C2C);
    const Color corBordaCinza = Color(0xFFE0E0E0);

    return PuncAppShell(
      selectedRoute: '/gerenciamento/novo',
      body: Container(
        color: corFundoPagina,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar motorista/caminhão',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: corTextoEscuro,
                ),
              ),
              Text(
                'Preencha os dados para adicionar um novo veículo.',
                style: TextStyle(
                  color: corTextoEscuro.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // Bloco de Informações do Motorista
              _buildContainer(
                child: Column(
                  children: [
                    const SectionHeader(
                      icon: Icons.person_outline,
                      title: 'Informações do motorista',
                    ),
                    _buildTextField(
                      controller: _nomeController,
                      label: 'Nome do motorista',
                      icon: Icons.person_outline,
                    ),
                    _buildTextField(
                      controller: _telefoneController,
                      label: 'Telefone',
                      icon: Icons.phone_android,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Bloco de Informações do Caminhão
              _buildContainer(
                child: Column(
                  children: [
                    const SectionHeader(
                      icon: Icons.local_shipping_outlined,
                      title: 'Informações do caminhão',
                    ),
                    _buildTextField(
                      controller: _numeroController,
                      label: 'ID do dispositivo (MAC)',
                      icon: Icons.tag_outlined,
                      helperText:
                          'Use o ID exibido no celular do motorista. '
                          'Ele identifica o aparelho no sistema.',
                    ),
                    _buildTextField(
                      controller: _placaController,
                      label: 'Placa do caminhão',
                      icon: Icons.credit_card_outlined,
                    ),
                    _buildTextField(
                      controller: _modeloController,
                      label: 'Modelo do caminhão',
                      icon: Icons.directions_car_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildStatusDropdown(corBotaoPrimario),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _salvando
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: corBordaCinza),
                        foregroundColor: corTextoEscuro,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corBotaoPrimario,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text('Salvar',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: !_salvando && !_carregandoMac,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          prefixIcon: Icon(icon, color: const Color(0xFF5E996E)),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF5E996E), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Color corBotao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: _salvando,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: corBotao, width: 2),
              ),
            ),
            items: ['Disponível', 'Em rota', 'Manutenção']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: _salvando
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}