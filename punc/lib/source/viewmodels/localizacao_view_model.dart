import '../data/modelos/localizacao_usuario.dart';
import '../data/servicos/servico_localizacao.dart';
import '../data/servicos/servico_notificacoes.dart';
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
    CadastrarUsuario? cadastrarUsuario,
  })  : _servicoLocalizacao = servicoLocalizacao ?? ServicoLocalizacao(),
        _servicoNotificacoes =
            servicoNotificacoes ?? ServicoNotificacoes(),
        _cadastrarUsuario = cadastrarUsuario ?? CadastrarUsuario();

  final ServicoLocalizacao _servicoLocalizacao;
  final ServicoNotificacoes _servicoNotificacoes;
  final CadastrarUsuario _cadastrarUsuario;

  Future<LocalizacaoUsuario> obterAtual() {
    return _servicoLocalizacao.obterLocalizacaoAtual();
  }

  Future<ResultadoConfiguracaoLocalizacao> configurarNotificacoes({
    required LocalizacaoUsuario localizacao,
  }) async {
    await _servicoNotificacoes.inicializar();
    final cadastro = await _cadastrarUsuario.executar(
      nomeDispositivo: 'Dispositivo do usuario',
      mac: '00:00:00:00:00:00',
      latitude: localizacao.latitude,
      longitude: localizacao.longitude,
    );
    final inscricao = await _servicoNotificacoes.inscreverUsuario(cadastro);

    return ResultadoConfiguracaoLocalizacao(
      localizacao: localizacao,
      inscricao: inscricao,
    );
  }
}
