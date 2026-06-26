import 'package:flutter/foundation.dart';

import '../data/modelos/tipo_lixo.dart';
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
  String? _tipoLixoSelecionado;
  String? _tipoLixoAtivo;
  String? _identificacaoCaminhaoSelecionada;
  String? _identificacaoCaminhaoAtiva;

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
  String? get tipoLixoSelecionado => _tipoLixoSelecionado;
  String? get tipoLixoAtivo => _tipoLixoAtivo;
  String? get tipoLixoExibicao {
    final valor = estaEmPercurso ? _tipoLixoAtivo : _tipoLixoSelecionado;
    if (valor == null) return null;
    return TipoLixo.rotulo(valor);
  }
  String? get identificacaoCaminhaoSelecionada =>
      _identificacaoCaminhaoSelecionada;
  String? get identificacaoCaminhaoAtiva => _identificacaoCaminhaoAtiva;
  String? get identificacaoCaminhaoExibicao => estaEmPercurso
      ? _identificacaoCaminhaoAtiva
      : _identificacaoCaminhaoSelecionada;

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
    String? tipoLixo,
    String? identificacaoCaminhao,
  }) {
    _idMotorista = idMotorista;
    _macDispositivo = macDispositivo;
    _nomeDispositivo = nomeDispositivo;
    _statusMotorista = _statusDeTexto(statusRemoto);
    final tipoNormalizado = TipoLixo.normalizar(tipoLixo);
    if (tipoNormalizado != null) {
      if (estaEmPercurso) {
        _tipoLixoAtivo = tipoNormalizado;
      } else {
        _tipoLixoSelecionado = tipoNormalizado;
      }
    }
    final identificacao = identificacaoCaminhao?.trim();
    if (identificacao != null && identificacao.isNotEmpty) {
      if (estaEmPercurso) {
        _identificacaoCaminhaoAtiva = identificacao;
      } else {
        _identificacaoCaminhaoSelecionada = identificacao;
      }
    }
    notifyListeners();
  }

  void definirTipoLixo(String tipoLixo) {
    final tipoNormalizado = TipoLixo.normalizar(tipoLixo);
    if (tipoNormalizado == null || estaEmPercurso) return;
    _tipoLixoSelecionado = tipoNormalizado;
    notifyListeners();
  }

  void definirIdentificacaoCaminhao(String identificacao) {
    if (estaEmPercurso) return;
    _identificacaoCaminhaoSelecionada = identificacao.trim();
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
    _tipoLixoSelecionado = null;
    _tipoLixoAtivo = null;
    _identificacaoCaminhaoSelecionada = null;
    _identificacaoCaminhaoAtiva = null;
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
  Future<bool> iniciarPercurso({
    String? tipoLixo,
    String? identificacaoCaminhao,
  }) async {
    if (_idMotorista == null || _macDispositivo == null) {
      _mensagemErro = 'Motorista não identificado.';
      notifyListeners();
      return false;
    }

    final tipoNormalizado =
        TipoLixo.normalizar(tipoLixo ?? _tipoLixoSelecionado);
    if (tipoNormalizado == null) {
      _mensagemErro = 'Selecione o tipo de lixo (orgânico ou reciclado).';
      notifyListeners();
      return false;
    }

    final identificacao =
        (identificacaoCaminhao ?? _identificacaoCaminhaoSelecionada)?.trim();
    if (identificacao == null || identificacao.isEmpty) {
      _mensagemErro = 'Informe a identificação do caminhão.';
      notifyListeners();
      return false;
    }

    try {
      _mensagemErro = null;

      await _repositorioMotorista.atualizarPercursoDispositivo(
        idMotorista: _idMotorista!,
        mac: _macDispositivo!,
        status: 'Em percurso',
        tipoLixo: tipoNormalizado,
        identificacaoCaminhao: identificacao,
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
      _tipoLixoAtivo = tipoNormalizado;
      _identificacaoCaminhaoAtiva = identificacao;
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
      _tipoLixoAtivo = null;
      _identificacaoCaminhaoAtiva = null;
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
