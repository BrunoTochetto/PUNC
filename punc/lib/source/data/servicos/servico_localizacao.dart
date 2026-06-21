import 'package:geolocator/geolocator.dart';

import '../../../nucleo/erros/excecoes.dart';
import '../modelos/localizacao_usuario.dart';

class ServicoLocalizacao {
  Future<LocalizacaoUsuario> obterLocalizacaoAtual() async {
    final permissaoConcedida = await _garantirPermissao();
    if (!permissaoConcedida) {
      throw const LocalizacaoExcecao(
        'Permissao de localizacao negada ou indisponivel.',
      );
    }

    final posicao = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocalizacaoUsuario(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      descricao: 'Sua localizacao atual',
      cep: '',
    );
  }

  /// Verifica se a permissão de localização está concedida sem solicitar novamente.
  /// Retorna true se o serviço está habilitado e a permissão foi concedida.
  Future<bool> verificarPermissao() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      return false;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    return permissao == LocationPermission.always ||
        permissao == LocationPermission.whileInUse;
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

    return permissao == LocationPermission.always ||
        permissao == LocationPermission.whileInUse;
  }
}
