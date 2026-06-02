import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/truck_card.dart';

class Gerenciamento2Page extends StatefulWidget {
  const Gerenciamento2Page({Key? key}) : super(key: key);

  @override
  State<Gerenciamento2Page> createState() => _Gerenciamento2PageState();
}

class _Gerenciamento2PageState extends State<Gerenciamento2Page> {
  String selectedStatus = 'Disponível';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHeader(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Novo motorista / caminhão',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Fixed typo blackDE
                      ),
                    ),
                    const Text(
                      'Motoristas e Caminhões',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Form Grid
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Nome do motorista',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustomTextField(
                            label: 'Telefone',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Número do caminhão',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustomTextField(
                            label: 'Placa do caminhão',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Modelo do caminhão',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedStatus,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedStatus = newValue;
                                        });
                                      }
                                    },
                                    items: <String>['Disponível', 'Em rota', 'Manutenção']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 35),
                    
                    // Save Button
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6767),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Preview Card
                    TruckCard(
                      title: 'Caminhão 01',
                      driver: 'Nicoly Quechini',
                      phone: '(49) 99914-2387',
                      truckNumber: '01',
                      plate: 'BTS-525',
                      model: 'Mercedsfvj',
                      route: 'Centro, 30 de Outubro',
                      status: 'Em rota',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}