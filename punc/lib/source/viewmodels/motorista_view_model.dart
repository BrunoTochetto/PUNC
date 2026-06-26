import 'package:flutter/foundation.dart';

import '../data/repositorios/repositorio_motorista.dart';
import '../data/servicos/servico_localizacao_motorista.dart';

/// Estados possíveis do motorista.
enum StatusMotorista {
  emPercurso,
  inativo,
}

/// ViewModel responsável por gerenciar o estado e operações do motorista.
///
/// Responsabilidades:
/// - Manter ID e dados do motorista autenticado
/// - Gerenciar status do motorista (Em percurso / Inativo)
/// - Controlar o serviço de coleta de localização baseado no status
/// - Fornecer estado reativo para a UI
/// - Lidar com erros e feedbacks ao usuário
class MotoristaViewModel extends ChangeNotifier {
  MotoristaViewModel({
    ServicoLocalizacaoMotorista? servicoLocalizacao,
    RepositorioMotorista? repositorioMotorista,
  })  : _servicoLocalizacao =
            servicoLocalizacao ?? ServicoLocalizacaoMotorista(),
        _repositorioMotorista =
            repositorioMotorista ?? RepositorioMotorista() {
    _inicializarCallbacks();
  }

  final ServicoLocalizacaoMotorista _servicoLocalizacao;
  final RepositorioMotorista _repositorioMotorista;

  // Estado do motorista
  int? _idMotorista;
  String? _macDispositivo;
  String? _nomeDispositivo;
  StatusMotorista _statusMotorista = StatusMotorista.inativo;
  String? _mensagemErro;
  bool _estaSincronizando = false;

  // Getters para acesso público
  int? get idMotorista => _idMotorista;
  String? get macDispositivo => _macDispositivo;
  String? get nomeDispositivo => _nomeDispositivo;
  bool get ehMotorista => _idMotorista != null;
  StatusMotorista get statusMotorista => _statusMotorista;
  String? get mensagemErro => _mensagemErro;
  bool get estaSincronizando => _estaSincronizando;
  bool get estaEmPercurso => _statusMotorista == StatusMotorista.emPercurso;
  bool get estaInativo => _statusMotorista == StatusMotorista.inativo;

  /// Inicializa os callbacks do serviço de localização.
  void _inicializarCallbacks() {
    _servicoLocalizacao.configurarCallbacks(
      onEstadoMudou: (novoEstado) {
        _estaSincronizando =
            novoEstado == EstadoLocalizacaoMotorista.enviando;
        notifyListeners();
      },
      onErro: (mensagem) {
        _mensagemErro = mensagem;
        notifyListeners();
      },
    );
  }

  /// Define o motorista autenticado pelo dispositivo.
  void definirMotorista({
    required int idMotorista,
    required String macDispositivo,
    String? nomeDispositivo,
    String? statusRemoto,
  }) {
    _idMotorista = idMotorista;
    _macDispositivo = macDispositivo;
    _nomeDispositivo = nomeDispositivo;
    _statusMotorista = _statusDeTexto(statusRemoto);
    notifyListeners();
  }

  /// Restaura coleta de localização se o motorista já estava em percurso.
  Future<void> sincronizarEstadoInicial() async {
    if (_idMotorista == null || _macDispositivo == null) return;
    if (!estaEmPercurso) return;

    final sucesso = await _servicoLocalizacao.iniciarColeta(
      idMotorista: _idMotorista!,
    );
    if (!sucesso) {
      _mensagemErro ??=
          'Não foi possível retomar o envio de localização.';
      notifyListeners();
    }
  }

  void limparMotorista() {
    _servicoLocalizacao.pararColeta();
    _idMotorista = null;
    _macDispositivo = null;
    _nomeDispositivo = null;
    _statusMotorista = StatusMotorista.inativo;
    _mensagemErro = null;
    notifyListeners();
  }

  StatusMotorista _statusDeTexto(String? status) {
    final texto = status?.toLowerCase() ?? '';
    if (texto.contains('percurso')) {
      return StatusMotorista.emPercurso;
    }
    return StatusMotorista.inativo;
  }

  /// Muda o status do motorista para "Em percurso" e inicia a coleta de localização.
  ///
  /// Retorna true se conseguir mudar o status e iniciar coleta, false caso contrário.
  Future<bool> iniciarPercurso() async {
    if (_idMotorista == null || _macDispositivo == null) {
      _mensagemErro = 'Motorista não identificado.';
      notifyListeners();
      return false;
    }

    try {
      _mensagemErro = null;

      await _repositorioMotorista.atualizarPercursoDispositivo(
        idMotorista: _idMotorista!,
        mac: _macDispositivo!,
        status: 'Em percurso',
      );

      final sucesso = await _servicoLocalizacao.iniciarColeta(
        idMotorista: _idMotorista!,
      );

      if (!sucesso) {
        await _repositorioMotorista.atualizarPercursoDispositivo(
          idMotorista: _idMotorista!,
          mac: _macDispositivo!,
          status: 'Inativo',
        );
        _mensagemErro ??=
            'Não foi possível iniciar coleta de localização.';
        notifyListeners();
        return false;
      }

      _statusMotorista = StatusMotorista.emPercurso;
      notifyListeners();

      debugPrint('[PUNC motorista] Percurso iniciado.');
      return true;
    } catch (e) {
      _mensagemErro = 'Erro ao iniciar percurso: $e';
      _servicoLocalizacao.pararColeta();
      notifyListeners();
      return false;
    }
  }

  /// Muda o status do motorista para "Inativo" e para a coleta de localização.
  ///
  /// Retorna true se conseguir mudar o status, false caso contrário.
  Future<bool> finalizarPercurso() async {
    if (_idMotorista == null || _macDispositivo == null) {
      _mensagemErro = 'Motorista não identificado.';
      notifyListeners();
      return false;
    }

    try {
      _mensagemErro = null;

      _servicoLocalizacao.pararColeta();

      await _repositorioMotorista.atualizarPercursoDispositivo(
        idMotorista: _idMotorista!,
        mac: _macDispositivo!,
        status: 'Inativo',
      );

      _statusMotorista = StatusMotorista.inativo;
      notifyListeners();

      debugPrint('[PUNC motorista] Percurso finalizado.');
      return true;
    } catch (e) {
      _mensagemErro = 'Erro ao finalizar percurso: $e';
      notifyListeners();
      return false;
    }
  }

  /// Limpa mensagem de erro.
  void limparErro() {
    _mensagemErro = null;
    notifyListeners();
  }

  /// Libera recursos do ViewModel.
  @override
  void dispose() {
    _servicoLocalizacao.dispose();
    super.dispose();
  }
}
