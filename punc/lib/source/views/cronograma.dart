import 'package:flutter/material.dart';
import '/source/widgets/card_coleta.dart';

class CronogramaPage extends StatelessWidget {
  const CronogramaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      // scaffoldBackgroundColor já está definido no PUNCAppTheme
      appBar: AppBar(
        // AppBarTheme já está definido no PUNCAppTheme
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.eco, color: Colors.white, size: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cronograma de coleta',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CardColeta(
                    day: 'Segunda-feira',
                    time: '12:30',
                    type: 'Reciclável',
                    iconColor: Colors.green,
                  ),
                  const CardColeta(
                    day: 'Terça-feira',
                    time: '08:45',
                    type: 'Orgânico',
                    iconColor: Colors.brown,
                  ),
                  const CardColeta(
                    day: 'Segunda-feira',
                    time: '12:30',
                    type: 'Reciclável',
                    iconColor: Colors.green,
                  ),
                  const CardColeta(
                    day: 'Segunda-feira',
                    time: '12:30',
                    type: 'Reciclável',
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      // Estilo do botão já vem do ElevatedButtonThemeData no PUNCAppTheme
                      child: const Text(
                        'Cronograma completo',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            color: theme.appBarTheme.backgroundColor, // Sincronizado com a cor do AppBar do tema
          ),
        ],
      ),
    );
  }
}
