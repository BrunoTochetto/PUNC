import 'package:flutter/foundation.dart';

import '../data/modelos/localizacao_usuario.dart';
import '../data/modelos/usuario.dart';
import '../data/servicos/servico_localizacao.dart';
import '../data/servicos/servico_notificacoes.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../domain/casodeuso/usuario/cadastrar_usuario.dart';

class ResultadoConfiguracaoLocalizacao {
  const ResultadoConfiguracaoLocalizacao({
    required this.localizacao,
    required this.cadastro,
    required this.inscricao,
    this.erroInscricao,
  });

  final LocalizacaoUsuario localizacao;
  final ResultadoCadastroUsuario cadastro;
  final InscricaoNotificacao inscricao;
  final String? erroInscricao;
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
    final tokenFcm = await _servicoNotificacoes.obterTokenFcm();
    debugPrint(
      '[PUNC notificacoes] token_fcm=${tokenFcm == null ? 'null' : '$tokenFcm caracteres'}',
    );

    final identificacao =
        await _preferenciasUsuario.obterIdentificacaoDispositivo();
    final cadastro = await _cadastrarUsuario.executar(
      nomeDispositivo: identificacao.nomeDispositivo,
      mac: identificacao.mac,
      latitude: localizacao.latitude,
      longitude: localizacao.longitude,
      fcmToken: tokenFcm,
    );
    debugPrint(
      '[PUNC notificacoes] usuario=${cadastro.usuario.id} '
      'celula=${cadastro.usuario.celula.x},${cadastro.usuario.celula.y} '
      'topico_backend=${cadastro.usuario.celula.topico} '
      'inscricao_backend=${cadastro.usuario.inscricaoFcm?.inscrito}',
    );

    late final InscricaoNotificacao inscricao;
    String? erroInscricao;
    try {
      inscricao = await _servicoNotificacoes.inscreverUsuario(cadastro);
    } catch (erro) {
      erroInscricao = erro.toString();
      inscricao = InscricaoNotificacao(
        inscrito: false,
        topico: ServicoNotificacoes.topicoParaCadastro(cadastro),
      );
    }

    debugPrint(
      '[PUNC notificacoes] inscricao_firebase=${inscricao.inscrito} '
      'topico=${inscricao.topico} erro=${erroInscricao ?? 'nenhum'}',
    );

    final inscritoNoBackend = cadastro.usuario.inscricaoFcm?.inscrito == true;
    if (inscricao.inscrito || inscritoNoBackend) {
      await _preferenciasUsuario.salvarConfiguracao(
        topico: inscricao.topico,
        idDispositivo: identificacao.mac,
      );
    }

    return ResultadoConfiguracaoLocalizacao(
      localizacao: localizacao,
      cadastro: cadastro,
      inscricao: inscricao,
      erroInscricao: erroInscricao,
    );
  }
}
