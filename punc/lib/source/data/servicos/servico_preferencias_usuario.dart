import 'dart:io';

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
  });

  final bool configurado;
  final String? topicoFcm;
  final String? idDispositivo;
}

class ServicoPreferenciasUsuario {
  static const _chaveConfigurado = 'usuario_configurado';
  static const _chaveTopico = 'topico_fcm';
  static const _chaveIdDispositivo = 'id_dispositivo';

  Future<PreferenciasUsuario> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenciasUsuario(
      configurado: prefs.getBool(_chaveConfigurado) ?? false,
      topicoFcm: prefs.getString(_chaveTopico),
      idDispositivo: prefs.getString(_chaveIdDispositivo),
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

  Future<IdentificacaoDispositivo> obterIdentificacaoDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final idDispositivo = prefs.getString(_chaveIdDispositivo) ??
        'PUNC-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';

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
}
