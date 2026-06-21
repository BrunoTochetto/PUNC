import 'dart:async';
import 'package:flutter/foundation.dart';

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
///
/// Responsabilidades:
/// - Iniciar/parar a coleta de localização baseado no status do motorista
/// - Obter localização em intervalos regulares (~30 segundos)
/// - Enviar localização ao backend
/// - Tratar erros de permissão, GPS e rede
/// - Notificar mudanças de estado e erros através de callbacks
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

  Timer? _timerLocalizacao;
  EstadoLocalizacaoMotorista _estadoAtual = EstadoLocalizacaoMotorista.inativo;

  // Callbacks para notificação de mudanças
  OnEstadoMudou? _onEstadoMudou;
  OnErro? _onErro;

  // ID do motorista e MAC para envio
  int? _idMotorista;
  String? _macDispositivo;

  // Intervalo de coleta (30 segundos)
  static const Duration intervaloColeta = Duration(seconds: 30);

  /// Estado atual da coleta de localização.
  EstadoLocalizacaoMotorista get estadoAtual => _estadoAtual;

  /// Define callbacks para notificação de mudanças e erros.
  void configurarCallbacks({
    required OnEstadoMudou onEstadoMudou,
    required OnErro onErro,
  }) {
    _onEstadoMudou = onEstadoMudou;
    _onErro = onErro;
  }

  /// Inicia a coleta periódica de localização do motorista.
  ///
  /// Deve ser chamado quando o motorista muda para status "Em percurso".
  /// Retorna true se iniciado com sucesso, false caso contrário.
  Future<bool> iniciarColeta({
    required int idMotorista,
  }) async {
    try {
      _idMotorista = idMotorista;

      // Obter MAC do dispositivo
      final preferencias = await _servicoPreferencias.carregar();
      _macDispositivo = preferencias.idDispositivo;

      if (_macDispositivo == null || _macDispositivo!.isEmpty) {
        _notificarErro(
          'MAC do dispositivo não configurado. '
          'Configure o dispositivo primeiro.',
        );
        return false;
      }

      // Verificar permissão de localização reutilizando o serviço existente
      final temPermissao = await _servicoLocalizacao.verificarPermissao();
      if (!temPermissao) {
        _notificarErro('Permissão de localização negada.');
        return false;
      }

      _mudarEstado(EstadoLocalizacaoMotorista.coletando);

      // Fazer envio imediato da primeira localização
      await _coletarEEnviarLocalizacao();

      // Iniciar timer para coleta periódica
      _timerLocalizacao = Timer.periodic(intervaloColeta, (_) {
        _coletarEEnviarLocalizacao();
      });

      debugPrint('[PUNC motorista] Coleta de localização iniciada.');
      return true;
    } catch (e) {
      _notificarErro('Erro ao iniciar coleta: $e');
      _mudarEstado(EstadoLocalizacaoMotorista.erro);
      return false;
    }
  }

  /// Para a coleta periódica de localização do motorista.
  ///
  /// Deve ser chamado quando o motorista muda para status "Inativo".
  void pararColeta() {
    _timerLocalizacao?.cancel();
    _timerLocalizacao = null;
    _idMotorista = null;
    _macDispositivo = null;
    _mudarEstado(EstadoLocalizacaoMotorista.inativo);
    debugPrint('[PUNC motorista] Coleta de localização parada.');
  }

  /// Coleta a localização atual e a envia ao backend.
  Future<void> _coletarEEnviarLocalizacao() async {
    if (_idMotorista == null || _macDispositivo == null) {
      return;
    }

    try {
      _mudarEstado(EstadoLocalizacaoMotorista.enviando);

      // Obter localização atual
      final localizacao = await _servicoLocalizacao.obterLocalizacaoAtual();

      // Enviar ao backend
      await _repositorioMotorista.enviarLocalizacao(
        idMotorista: _idMotorista!,
        mac: _macDispositivo!,
        latitude: localizacao.latitude,
        longitude: localizacao.longitude,
      );

      _mudarEstado(EstadoLocalizacaoMotorista.coletando);

      debugPrint(
        '[PUNC motorista] Localização enviada: '
        'lat=${localizacao.latitude}, lon=${localizacao.longitude}',
      );
    } catch (e) {
      _notificarErro('Erro ao enviar localização: $e');
      _mudarEstado(EstadoLocalizacaoMotorista.erro);
    }
  }

  /// Notifica uma mudança de estado através do callback.
  void _mudarEstado(EstadoLocalizacaoMotorista novoEstado) {
    if (_estadoAtual != novoEstado) {
      _estadoAtual = novoEstado;
      _onEstadoMudou?.call(novoEstado);
    }
  }

  /// Notifica um erro através do callback.
  void _notificarErro(String mensagem) {
    debugPrint('[PUNC motorista] Erro: $mensagem');
    _onErro?.call(mensagem);
  }

  /// Limpa recursos do serviço.
  void dispose() {
    pararColeta();
    _onEstadoMudou = null;
    _onErro = null;
  }
}
