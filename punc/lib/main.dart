import 'package:flutter/material.dart';
import './nucleo/temas/appTheme.dart';

void main() {
  runApp(
    MaterialApp(
      theme: PUNCAppTheme.theme,
      darkTheme: PUNCAppTheme.darkTheme,
      home: Configuracoes(),
      
    )
  );
}

/* 
Essa aba de configurações ainda vai mudar, mas vai funcionar assim.

SE for a primeira vez que a pessoa abre o aplicativo:
    Aparece uma aba de configurações explicando o que é o aplicativo;
    Pergunta se o usuário está em SUA CASA:
      Se SIM:
        Pede a permissão para acessar a localização agora e registrar ele na sua localização atual.

      Se NÃO:
        Mostra uma mensagem "Apenas pediremos a sua localização quando você estiver em casa... Lembraremos você daqui meia hora!";
        Começa um temporizador de 30 minutos, quando acabar envia uma notificação para o mesmo lembrando de colocar a localização de sua casa.
          Repete até o usuário estar em casa.
    
    Então, o usuário será levado para a tela do mapa.
    E todas as vezes que um usuário que já tem sua localização definida, já começa no mapa.

*/
class Configuracoes extends StatelessWidget {
  const Configuracoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}