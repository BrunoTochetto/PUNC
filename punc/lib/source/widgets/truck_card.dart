import 'package:flutter/material.dart';

class TruckCard extends StatelessWidget {
  final String title;
  final String driver;
  final String phone;
  final String truckNumber;
  final String plate;
  final String model;
  final String route;
  final String status;

  const TruckCard({
    super.key,
    required this.title,
    required this.driver,
    required this.phone,
    required this.truckNumber,
    required this.plate,
    required this.model,
    required this.route,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Truck Image Placeholder
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Truck Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Motorista:', driver),
                _buildInfoRow('Telefone:', phone),
                _buildInfoRow('Número do caminhão:', truckNumber),
                _buildInfoRow('Placa:', plate),
                _buildInfoRow('Modelo:', model),
                _buildInfoRow('Rota atual:', route),
                _buildInfoRow('Status:', status),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16, color: Colors.green),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
