import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentificacaoDispositivo {
  const IdentificacaoDispositivo({
    required this.nomeDispositivo,
    required this.mac,
  });

  final String nomeDispositivo;
  final String mac;
}

class PreferenciasUsuario {
  const PreferenciasUsuario({
    required this.configurado,
    this.topicoFcm,
    this.idDispositivo,
    this.cep,
  });

  final bool configurado;
  final String? topicoFcm;
  final String? idDispositivo;
  final String? cep;
}

class ServicoPreferenciasUsuario {
  static const _chaveConfigurado = 'usuario_configurado';
  static const _chaveTopico = 'topico_fcm';
  static const _chaveIdDispositivo = 'id_dispositivo';
  static const _chaveCep = 'cep_usuario';
  static final RegExp _macRegex = RegExp(
    r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$',
  );

  Future<PreferenciasUsuario> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenciasUsuario(
      configurado: prefs.getBool(_chaveConfigurado) ?? false,
      topicoFcm: prefs.getString(_chaveTopico),
      idDispositivo: prefs.getString(_chaveIdDispositivo),
      cep: prefs.getString(_chaveCep),
    );
  }

  Future<void> salvarConfiguracao({
    required String topico,
    required String idDispositivo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveConfigurado, true);
    await prefs.setString(_chaveTopico, topico);
    await prefs.setString(_chaveIdDispositivo, idDispositivo);
  }

  Future<void> salvarCep(String cep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCep, cep);
  }

  Future<IdentificacaoDispositivo> obterIdentificacaoDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    var idDispositivo = prefs.getString(_chaveIdDispositivo);
    if (idDispositivo == null || !_macRegex.hasMatch(idDispositivo)) {
      idDispositivo = _gerarMacLocal();
      await prefs.setString(_chaveIdDispositivo, idDispositivo);
    }

    final plugin = DeviceInfoPlugin();
    var nomeDispositivo = 'Dispositivo PUNC';

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      nomeDispositivo = '${info.brand} ${info.model}'.trim();
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      nomeDispositivo = info.name;
    }

    if (nomeDispositivo.isEmpty) {
      nomeDispositivo = 'Dispositivo PUNC';
    }

    return IdentificacaoDispositivo(
      nomeDispositivo: nomeDispositivo,
      mac: idDispositivo,
    );
  }

  String _gerarMacLocal() {
    final random = Random.secure();
    final bytes = List<int>.generate(6, (_) => random.nextInt(256));

    // Endereco localmente administrado e unicast. Nao representa o MAC real.
    bytes[0] = (bytes[0] | 0x02) & 0xFE;

    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}
