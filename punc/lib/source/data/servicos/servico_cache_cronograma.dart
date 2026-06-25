import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/horario_coleta.dart';

class CacheCronograma {
  const CacheCronograma({
    required this.horarios,
    required this.hash,
    required this.sincronizadoEm,
  });

  final List<HorarioColeta> horarios;
  final String hash;
  final DateTime sincronizadoEm;
}

class ServicoCacheCronograma {
  ServicoCacheCronograma({Box? box}) : _box = box;

  static const _nomeBox = 'cronograma';
  static const _chaveCacheLegado = 'cronograma_cache';
  static const _prefixoChave = 'cep_';

  Box? _box;
  bool _migracaoFeita = false;

  Future<Box> _obterBox() async {
    if (_box != null) return _box!;
    if (Hive.isBoxOpen(_nomeBox)) {
      _box = Hive.box(_nomeBox);
      return _box!;
    }
    _box = await Hive.openBox(_nomeBox);
    return _box!;
  }

  static String normalizarCep(String cep) {
    return cep.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String hashHorarios(List<HorarioColeta> horarios) {
    final serializado = horarios.map((h) => h.toJson()).toList()
      ..sort((a, b) {
        final chaveA =
            '${a['dia_semana']}_${a['horario_estimado']}_${a['tipo_lixo']}';
        final chaveB =
            '${b['dia_semana']}_${b['horario_estimado']}_${b['tipo_lixo']}';
        return chaveA.compareTo(chaveB);
      });
    return jsonEncode(serializado);
  }

  Future<void> _migrarCacheLegado(String cep) async {
    if (_migracaoFeita) return;
    _migracaoFeita = true;

    final prefs = await SharedPreferences.getInstance();
    final jsonLegado = prefs.getString(_chaveCacheLegado);
    if (jsonLegado == null || jsonLegado.isEmpty) return;

    try {
      final lista = jsonDecode(jsonLegado) as List<dynamic>;
      final horarios = lista
          .map((item) => HorarioColeta.fromJson(item as Map<String, dynamic>))
          .toList();
      if (horarios.isNotEmpty && cep.isNotEmpty) {
        await salvar(cep: cep, horarios: horarios);
      }
      await prefs.remove(_chaveCacheLegado);
    } catch (_) {
      // Ignora dados corrompidos do cache legado.
    }
  }

  Future<CacheCronograma?> carregar(String cep) async {
    final cepNormalizado = normalizarCep(cep);
    if (cepNormalizado.isEmpty) return null;

    await _migrarCacheLegado(cepNormalizado);

    final box = await _obterBox();
    final dados = box.get('$_prefixoChave$cepNormalizado');
    if (dados is! Map) return null;

    try {
      final mapa = Map<String, dynamic>.from(dados);
      final horariosJson = mapa['horarios'] as List<dynamic>? ?? [];
      final horarios = horariosJson
          .map((item) => HorarioColeta.fromMap(item as Map<dynamic, dynamic>))
          .toList();

      final sincronizadoEm = DateTime.tryParse(
            mapa['sincronizado_em']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return CacheCronograma(
        horarios: horarios,
        hash: mapa['hash']?.toString() ?? '',
        sincronizadoEm: sincronizadoEm,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> salvar({
    required String cep,
    required List<HorarioColeta> horarios,
  }) async {
    final cepNormalizado = normalizarCep(cep);
    if (cepNormalizado.isEmpty) return;

    final box = await _obterBox();
    final hash = hashHorarios(horarios);
    final agora = DateTime.now().toIso8601String();

    await box.put('$_prefixoChave$cepNormalizado', {
      'horarios': horarios.map((h) => h.toJson()).toList(),
      'hash': hash,
      'sincronizado_em': agora,
    });
  }

  Future<void> limpar(String cep) async {
    final cepNormalizado = normalizarCep(cep);
    if (cepNormalizado.isEmpty) return;

    final box = await _obterBox();
    await box.delete('$_prefixoChave$cepNormalizado');
  }
}
