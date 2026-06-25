import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/modelos/horario_coleta.dart';
import '../data/servicos/servico_cache_cronograma.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../domain/casodeuso/usuario/consultar_cronograma_coleta.dart';

class ResultadoCarregamentoCronograma {
  const ResultadoCarregamentoCronograma({
    required this.horarios,
    required this.cep,
    this.doCache = false,
    this.sincronizando = false,
    this.mensagemErro,
    this.ultimaSincronizacao,
  });

  final List<HorarioColeta> horarios;
  final String cep;
  final bool doCache;
  final bool sincronizando;
  final String? mensagemErro;
  final DateTime? ultimaSincronizacao;

  static const vazio = ResultadoCarregamentoCronograma(
    horarios: [],
    cep: '',
  );
}

class CronogramaViewModel {
  CronogramaViewModel({
    ConsultarCronogramaColeta? consultarCronograma,
    ServicoPreferenciasUsuario? preferencias,
    ServicoCacheCronograma? cache,
  })  : _consultarCronograma =
            consultarCronograma ?? ConsultarCronogramaColeta(),
        _preferencias = preferencias ?? ServicoPreferenciasUsuario(),
        _cache = cache ?? ServicoCacheCronograma();

  final ConsultarCronogramaColeta _consultarCronograma;
  final ServicoPreferenciasUsuario _preferencias;
  final ServicoCacheCronograma _cache;

  Future<ResultadoCarregamentoCronograma> carregarSomenteCache({
    String cep = '',
  }) async {
    final cepFinal = await _resolverCep(cep);
    if (cepFinal.isEmpty) {
      return ResultadoCarregamentoCronograma.vazio;
    }

    final cache = await _cache.carregar(cepFinal);
    if (cache == null || cache.horarios.isEmpty) {
      return ResultadoCarregamentoCronograma(horarios: [], cep: cepFinal);
    }

    return ResultadoCarregamentoCronograma(
      horarios: cache.horarios,
      cep: cepFinal,
      doCache: true,
      ultimaSincronizacao: cache.sincronizadoEm,
    );
  }

  Future<ResultadoCarregamentoCronograma> buscarNaRede({
    required String cep,
  }) async {
    final cepFinal = ServicoCacheCronograma.normalizarCep(cep);
    if (cepFinal.isEmpty) {
      return ResultadoCarregamentoCronograma.vazio;
    }

    debugPrint('[PUNC cronograma] Buscando horarios para CEP $cepFinal');

    try {
      final resultado = await _consultarCronograma.executar(cep: cepFinal);
      debugPrint(
        '[PUNC cronograma] ${resultado.length} horario(s) recebido(s)',
      );

      if (resultado.isEmpty) {
        await _cache.limpar(cepFinal);
        return ResultadoCarregamentoCronograma(
          horarios: const [],
          cep: cepFinal,
        );
      }

      await _cache.salvar(cep: cepFinal, horarios: resultado);
      final cacheAtualizado = await _cache.carregar(cepFinal);

      return ResultadoCarregamentoCronograma(
        horarios: resultado,
        cep: cepFinal,
        ultimaSincronizacao: cacheAtualizado?.sincronizadoEm,
      );
    } catch (erro) {
      debugPrint('[PUNC cronograma] Erro na busca: $erro');

      final cache = await _cache.carregar(cepFinal);
      if (cache != null && cache.horarios.isNotEmpty) {
        return ResultadoCarregamentoCronograma(
          horarios: cache.horarios,
          cep: cepFinal,
          doCache: true,
          mensagemErro: 'Sem conexao. Exibindo dados salvos.',
          ultimaSincronizacao: cache.sincronizadoEm,
        );
      }

      return ResultadoCarregamentoCronograma(
        horarios: const [],
        cep: cepFinal,
        mensagemErro: 'Nao foi possivel consultar o servidor. Verifique a conexao.',
      );
    }
  }

  Future<String> _resolverCep(String cep) async {
    if (cep.isNotEmpty) {
      return ServicoCacheCronograma.normalizarCep(cep);
    }

    final prefs = await _preferencias.carregar();
    return ServicoCacheCronograma.normalizarCep(prefs.cep ?? '');
  }
}
