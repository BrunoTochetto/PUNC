import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import './nucleo/temas/appTheme.dart';
import './source/data/servicos/servico_notificacoes.dart';
import './source/views/configuracao_usuario_page.dart';
import './source/views/cronograma.dart';
import './source/views/debug_notificacoes_page.dart';
import './source/views/gerenciamento.dart';
import './source/views/gerenciamento2.dart';
import './source/views/localizacao_atual_page.dart';
import './source/views/mapa_grupos_page.dart';
import './source/views/pagina_entrada.dart';
import './source/views/perfil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(servicoNotificacoesBackgroundHandler);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: PUNCAppTheme.theme,
      darkTheme: PUNCAppTheme.darkTheme,
      home: const PaginaEntrada(),
      routes: {
        '/cronograma': (_) => const CronogramaPage(),
        '/mapa': (_) => const MapaGruposPage(),
        '/localizacao': (_) => const LocalizacaoAtualPage(),
        '/gerenciamento': (_) => const GerenciamentoPage(),
        '/gerenciamento/novo': (_) => const Gerenciamento2Page(),
        '/perfil': (_) => const PerfilPage(),
        '/configuracoes': (_) => const ConfiguracaoUsuarioPage(),
        '/debug-notificacoes': (_) => const DebugNotificacoesPage(),
      },
    ),
  );
}

/* 
Essa aba de configurações ainda vai mudar, mas vai funcionar assim.

SE for a primeira vez que a pessoa abre o aplicativo:
    Aparece uma aba de configurações explicando o que é o aplicativo;
    Pergunta se o usuário está em SUA CASA:
      Se SIM:
        Pede a permissão para acessar a localização agora e registrar 
        ele na sua localização atual.

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
