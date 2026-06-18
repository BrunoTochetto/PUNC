import '../data/modelos/localizacao_usuario.dart';
import '../data/servicos/servico_localizacao.dart';
import '../data/servicos/servico_notificacoes.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../domain/casodeuso/usuario/cadastrar_usuario.dart';

class ResultadoConfiguracaoLocalizacao {
  const ResultadoConfiguracaoLocalizacao({
    required this.localizacao,
    required this.inscricao,
  });

  final LocalizacaoUsuario localizacao;
  final InscricaoNotificacao inscricao;
}

class LocalizacaoViewModel {
  LocalizacaoViewModel({
    ServicoLocalizacao? servicoLocalizacao,
    ServicoNotificacoes? servicoNotificacoes,
    ServicoPreferenciasUsuario? preferenciasUsuario,
    CadastrarUsuario? cadastrarUsuario,
  })  : _servicoLocalizacao = servicoLocalizacao ?? ServicoLocalizacao(),
        _servicoNotificacoes =
            servicoNotificacoes ?? ServicoNotificacoes(),
        _preferenciasUsuario =
            preferenciasUsuario ?? ServicoPreferenciasUsuario(),
        _cadastrarUsuario = cadastrarUsuario ?? CadastrarUsuario();

  final ServicoLocalizacao _servicoLocalizacao;
  final ServicoNotificacoes _servicoNotificacoes;
  final ServicoPreferenciasUsuario _preferenciasUsuario;
  final CadastrarUsuario _cadastrarUsuario;

  Future<LocalizacaoUsuario> obterAtual() {
    return _servicoLocalizacao.obterLocalizacaoAtual();
  }

  Future<ResultadoConfiguracaoLocalizacao> configurarNotificacoes({
    required LocalizacaoUsuario localizacao,
  }) async {
    await _servicoNotificacoes.inicializar();

    final identificacao =
        await _preferenciasUsuario.obterIdentificacaoDispositivo();
    final cadastro = await _cadastrarUsuario.executar(
      nomeDispositivo: identificacao.nomeDispositivo,
      mac: identificacao.mac,
      latitude: localizacao.latitude,
      longitude: localizacao.longitude,
    );
    final inscricao = await _servicoNotificacoes.inscreverUsuario(cadastro);

    await _preferenciasUsuario.salvarConfiguracao(
      topico: inscricao.topico,
      idDispositivo: identificacao.mac,
    );

    return ResultadoConfiguracaoLocalizacao(
      localizacao: localizacao,
      inscricao: inscricao,
    );
  }
}
