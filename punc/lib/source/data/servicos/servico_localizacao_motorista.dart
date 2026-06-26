import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../repositorios/repositorio_motorista.dart';
import 'servico_localizacao.dart';
import 'servico_preferencias_usuario.dart';

/// Estados possíveis do motorista durante a coleta de localização.
enum EstadoLocalizacaoMotorista {
  inativo,
  coletando,
  enviando,
  erro,
}

/// Callback para notificar mudanças de estado da coleta de localização.
typedef OnEstadoMudou = void Function(EstadoLocalizacaoMotorista novoEstado);

/// Callback para notificar erros durante a coleta de localização.
typedef OnErro = void Function(String mensagem);

/// Serviço responsável por gerenciar a coleta e envio periódico de localização do motorista.
class ServicoLocalizacaoMotorista {
  ServicoLocalizacaoMotorista({
    ServicoLocalizacao? servicoLocalizacao,
    ServicoPreferenciasUsuario? servicoPreferencias,
    RepositorioMotorista? repositorioMotorista,
  })  : _servicoLocalizacao = servicoLocalizacao ?? ServicoLocalizacao(),
        _servicoPreferencias =
            servicoPreferencias ?? ServicoPreferenciasUsuario(),
        _repositorioMotorista =
            repositorioMotorista ?? RepositorioMotorista();

  final ServicoLocalizacao _servicoLocalizacao;
  final ServicoPreferenciasUsuario _servicoPreferencias;
  final RepositorioMotorista _repositorioMotorista;

  StreamSubscription<Position>? _assinaturaLocalizacao;
  EstadoLocalizacaoMotorista _estadoAtual = EstadoLocalizacaoMotorista.inativo;
  DateTime? _ultimoEnvio;

  OnEstadoMudou? _onEstadoMudou;
  OnErro? _onErro;

  int? _idMotorista;
  String? _macDispositivo;

  static const Duration intervaloColeta =
      ServicoLocalizacao.intervaloColetaMotorista;

  EstadoLocalizacaoMotorista get estadoAtual => _estadoAtual;

  void configurarCallbacks({
    required OnEstadoMudou onEstadoMudou,
    required OnErro onErro,
  }) {
    _onEstadoMudou = onEstadoMudou;
    _onErro = onErro;
  }

  Future<bool> iniciarColeta({
    required int idMotorista,
  }) async {
    try {
      _idMotorista = idMotorista;

      final preferencias = await _servicoPreferencias.carregar();
      _macDispositivo = preferencias.idDispositivo;

      if (_macDispositivo == null || _macDispositivo!.isEmpty) {
        _notificarErro(
          'MAC do dispositivo não configurado. '
          'Configure o dispositivo primeiro.',
        );
        return false;
      }

      final temPermissao =
          await _servicoLocalizacao.garantirPermissaoSegundoPlano();
      if (!temPermissao) {
        _notificarErro('Permissão de localização negada.');
        return false;
      }

      _mudarEstado(EstadoLocalizacaoMotorista.coletando);

      final posicaoInicial = await Geolocator.getCurrentPosition(
        locationSettings: _servicoLocalizacao.configuracoesColetaMotorista(),
      ).timeout(const Duration(seconds: 15));
      await _enviarPosicao(posicaoInicial);

      final settings = _servicoLocalizacao.configuracoesColetaMotorista();
      await _assinaturaLocalizacao?.cancel();
      _assinaturaLocalizacao = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        _processarPosicao,
        onError: (Object erro) {
          _notificarErro('Erro na coleta de localização: $erro');
          _mudarEstado(EstadoLocalizacaoMotorista.erro);
        },
      );

      debugPrint(
        '[PUNC motorista] Coleta de localização iniciada (2º plano).',
      );
      return true;
    } catch (e) {
      _notificarErro('Erro ao iniciar coleta: $e');
      _mudarEstado(EstadoLocalizacaoMotorista.erro);
      return false;
    }
  }

  void pararColeta() {
    _assinaturaLocalizacao?.cancel();
    _assinaturaLocalizacao = null;
    _ultimoEnvio = null;
    _idMotorista = null;
    _macDispositivo = null;
    _mudarEstado(EstadoLocalizacaoMotorista.inativo);
    debugPrint('[PUNC motorista] Coleta de localização parada.');
  }

  Future<void> _processarPosicao(Position posicao) async {
    final agora = DateTime.now();
    if (_ultimoEnvio != null &&
        agora.difference(_ultimoEnvio!) < intervaloColeta) {
      return;
    }

    await _enviarPosicao(posicao);
  }

  Future<void> _enviarPosicao(Position posicao) async {
    if (_idMotorista == null || _macDispositivo == null) {
      return;
    }

    try {
      _mudarEstado(EstadoLocalizacaoMotorista.enviando);

      await _repositorioMotorista.enviarLocalizacao(
        idMotorista: _idMotorista!,
        mac: _macDispositivo!,
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );

      _ultimoEnvio = DateTime.now();
      _mudarEstado(EstadoLocalizacaoMotorista.coletando);

      debugPrint(
        '[PUNC motorista] Localização enviada: '
        'lat=${posicao.latitude}, lon=${posicao.longitude}',
      );
    } catch (e) {
      _notificarErro('Erro ao enviar localização: $e');
      _mudarEstado(EstadoLocalizacaoMotorista.erro);
    }
  }

  void _mudarEstado(EstadoLocalizacaoMotorista novoEstado) {
    if (_estadoAtual != novoEstado) {
      _estadoAtual = novoEstado;
      _onEstadoMudou?.call(novoEstado);
    }
  }

  void _notificarErro(String mensagem) {
    debugPrint('[PUNC motorista] Erro: $mensagem');
    _onErro?.call(mensagem);
  }

  void dispose() {
    pararColeta();
    _onEstadoMudou = null;
    _onErro = null;
  }
}
