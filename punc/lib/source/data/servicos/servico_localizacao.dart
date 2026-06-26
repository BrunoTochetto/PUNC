import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../nucleo/erros/excecoes.dart';
import '../modelos/localizacao_usuario.dart';

class ServicoLocalizacao {
  static const Duration intervaloColetaMotorista = Duration(seconds: 30);

  Future<LocalizacaoUsuario> obterLocalizacaoAtual() async {
    final permissaoConcedida = await _garantirPermissao();
    if (!permissaoConcedida) {
      throw const LocalizacaoExcecao(
        'Permissao de localizacao negada ou indisponivel.',
      );
    }

    final posicao = await Geolocator.getCurrentPosition(
      locationSettings: configuracoesColetaMotorista(),
    ).timeout(const Duration(seconds: 15));

    return LocalizacaoUsuario(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      descricao: 'Sua localizacao atual',
      cep: '',
    );
  }

  /// Configurações para coleta contínua do motorista (inclui serviço em 1º plano).
  LocationSettings configuracoesColetaMotorista() {
    if (!kIsWeb && Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        intervalDuration: intervaloColetaMotorista,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'PUNC',
          notificationText: 'Percurso ativo',
          notificationChannelName: 'Percurso motorista',
          notificationIcon: AndroidResource(
            name: 'launcher_icon',
            defType: 'mipmap',
          ),
          setOngoing: true,
          enableWakeLock: true,
        ),
      );
    }

    if (!kIsWeb && Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  /// Verifica se a permissão de localização está concedida sem solicitar novamente.
  Future<bool> verificarPermissao() async {
    return _temPermissaoUtil(await _obterPermissaoAtual());
  }

  /// Garante permissão para coleta em segundo plano durante o percurso.
  Future<bool> garantirPermissaoSegundoPlano() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      return false;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.whileInUse &&
        !kIsWeb &&
        Platform.isAndroid) {
      permissao = await Geolocator.requestPermission();
    }

    return _temPermissaoUtil(permissao);
  }

  Future<bool> _garantirPermissao() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      return false;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    return _temPermissaoUtil(permissao);
  }

  Future<LocationPermission> _obterPermissaoAtual() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      return LocationPermission.denied;
    }

    return Geolocator.checkPermission();
  }

  bool _temPermissaoUtil(LocationPermission permissao) {
    return permissao == LocationPermission.always ||
        permissao == LocationPermission.whileInUse;
  }
}
