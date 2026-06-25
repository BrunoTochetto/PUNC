import '../../../nucleo/erros/excecoes.dart';
import '../data/servicos/servico_localizacao.dart';
import '../data/servicos/servico_notificacoes.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import 'cronograma_view_model.dart';
import 'localizacao_view_model.dart';

class ResultadoReinicio {
  const ResultadoReinicio({
    required this.sucesso,
    this.topico,
    this.mensagem,
    this.cronogramaAtualizado = false,
  });

  final bool sucesso;
  final String? topico;
  final String? mensagem;
  final bool cronogramaAtualizado;
}

class ConfiguracaoViewModel {
  ConfiguracaoViewModel({
    ServicoLocalizacao? servicoLocalizacao,
    LocalizacaoViewModel? localizacaoViewModel,
    ServicoNotificacoes? servicoNotificacoes,
    ServicoPreferenciasUsuario? preferencias,
    CronogramaViewModel? cronogramaViewModel,
  })  : _servicoLocalizacao = servicoLocalizacao ?? ServicoLocalizacao(),
        _localizacaoViewModel =
            localizacaoViewModel ?? LocalizacaoViewModel(),
        _servicoNotificacoes =
            servicoNotificacoes ?? ServicoNotificacoes(),
        _preferencias = preferencias ?? ServicoPreferenciasUsuario(),
        _cronogramaViewModel =
            cronogramaViewModel ?? CronogramaViewModel();

  final ServicoLocalizacao _servicoLocalizacao;
  final LocalizacaoViewModel _localizacaoViewModel;
  final ServicoNotificacoes _servicoNotificacoes;
  final ServicoPreferenciasUsuario _preferencias;
  final CronogramaViewModel _cronogramaViewModel;

  Future<ResultadoReinicio> reiniciarTopicoFcm() async {
    try {
      final localizacao = await _servicoLocalizacao.obterLocalizacaoAtual();
      final resultado = await _localizacaoViewModel.configurarNotificacoes(
        localizacao: localizacao,
      );

      final topico = resultado.inscricao.topico;
      await _servicoNotificacoes.reiniciarTopico(topico);

      if (resultado.erroInscricao != null) {
        return ResultadoReinicio(
          sucesso: true,
          topico: topico,
          mensagem:
              'Topico atualizado, mas a inscricao no Firebase pode ter falhado.',
        );
      }

      return ResultadoReinicio(
        sucesso: true,
        topico: topico,
        mensagem: 'Topico FCM reiniciado com sucesso.',
      );
    } on LocalizacaoExcecao {
      return const ResultadoReinicio(
        sucesso: false,
        mensagem:
            'Permissao de localizacao negada. Ative nas configuracoes do sistema.',
      );
    } on NotificacaoExcecao catch (erro) {
      return ResultadoReinicio(
        sucesso: false,
        mensagem: erro.mensagem,
      );
    } catch (_) {
      return const ResultadoReinicio(
        sucesso: false,
        mensagem:
            'Nao foi possivel reiniciar o topico. Verifique a conexao e tente novamente.',
      );
    }
  }

  Future<ResultadoReinicio> reiniciarAmbos() async {
    final resultadoTopico = await reiniciarTopicoFcm();
    if (!resultadoTopico.sucesso) {
      return resultadoTopico;
    }

    final prefs = await _preferencias.carregar();
    final cep = prefs.cep?.trim() ?? '';
    if (cep.isEmpty) {
      return ResultadoReinicio(
        sucesso: true,
        topico: resultadoTopico.topico,
        mensagem:
            'Topico reiniciado. Informe um CEP para atualizar o cronograma.',
        cronogramaAtualizado: false,
      );
    }

    final cronograma = await _cronogramaViewModel.buscarNaRede(cep: cep);
    if (cronograma.mensagemErro != null) {
      return ResultadoReinicio(
        sucesso: true,
        topico: resultadoTopico.topico,
        mensagem:
            'Topico reiniciado, mas o cronograma nao foi atualizado: ${cronograma.mensagemErro}',
        cronogramaAtualizado: false,
      );
    }

    return ResultadoReinicio(
      sucesso: true,
      topico: resultadoTopico.topico,
      mensagem: 'Topico e cronograma atualizados com sucesso.',
      cronogramaAtualizado: true,
    );
  }
}
