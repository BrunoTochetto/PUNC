import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../../firebase_options.dart';
import '../../../nucleo/erros/excecoes.dart';
import '../modelos/usuario.dart';

@pragma('vm:entry-point')
Future<void> servicoNotificacoesBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificacaoRecebida {
  const NotificacaoRecebida({
    required this.titulo,
    required this.corpo,
    required this.dados,
  });

  final String? titulo;
  final String? corpo;
  final Map<String, dynamic> dados;
}

class InscricaoNotificacao {
  const InscricaoNotificacao({
    required this.inscrito,
    required this.topico,
  });

  final bool inscrito;
  final String topico;
}

class ServicoNotificacoes {
  ServicoNotificacoes({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final _notificacoesController =
      StreamController<NotificacaoRecebida>.broadcast();

  String? _topicoAtual;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  Stream<NotificacaoRecebida> get notificacoes =>
      _notificacoesController.stream;

  Future<void> inicializar() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await _solicitarPermissao();
    await _aguardarTokenApnsSeNecessario();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription ??=
        FirebaseMessaging.onMessage.listen(_processarMensagem);
    _openedAppSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(_processarMensagem);

    final mensagemInicial = await _messaging.getInitialMessage();
    if (mensagemInicial != null) {
      _processarMensagem(mensagemInicial);
    }
  }

  Future<InscricaoNotificacao> inscreverUsuario(
    ResultadoCadastroUsuario cadastro,
  ) async {
    final topico = topicoParaCadastro(cadastro);

    try {
      await inscreverNoTopico(topico);
      return InscricaoNotificacao(inscrito: true, topico: topico);
    } catch (e) {
      if (e is NotificacaoExcecao) {
        rethrow;
      }
      throw NotificacaoExcecao(
        'Nao foi possivel inscrever no topico $topico: $e',
      );
    }
  }

  Future<void> inscreverNoTopico(String topico) async {
    try {
      await _inscreverTopico(topico);
    } catch (e) {
      throw NotificacaoExcecao(
        'Nao foi possivel inscrever no topico $topico: $e',
      );
    }
  }

  static String topicoParaCadastro(ResultadoCadastroUsuario cadastro) {
    final x = cadastro.usuario.celula.x;
    final y = cadastro.usuario.celula.y;
    if (x == null || y == null) {
      throw const NotificacaoExcecao(
        'Backend nao retornou a celula do usuario.',
      );
    }
    return 'celula-$x-$y';
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    _notificacoesController.close();
  }

  Future<void> _inscreverTopico(String topico) async {
    if (_topicoAtual == topico) {
      return;
    }

    if (_topicoAtual != null) {
      await _messaging.unsubscribeFromTopic(_topicoAtual!);
    }

    await _messaging.subscribeToTopic(topico);
    _topicoAtual = topico;
  }

  Future<void> _solicitarPermissao() async {
    final configuracoes = await _messaging.requestPermission();

    if (configuracoes.authorizationStatus == AuthorizationStatus.denied) {
      throw const NotificacaoExcecao(
        'Permissao de notificacoes negada pelo usuario.',
      );
    }
  }

  Future<void> _aguardarTokenApnsSeNecessario() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      await _messaging.getToken();
      return;
    }

    for (var tentativa = 0; tentativa < 5; tentativa++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        await _messaging.getToken();
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    throw const NotificacaoExcecao(
      'Token APNS indisponivel para registrar notificacoes.',
    );
  }

  void _processarMensagem(RemoteMessage message) {
    if (_notificacoesController.isClosed) {
      return;
    }

    _notificacoesController.add(
      NotificacaoRecebida(
        titulo: message.notification?.title,
        corpo: message.notification?.body,
        dados: Map<String, dynamic>.from(message.data),
      ),
    );
  }
}
