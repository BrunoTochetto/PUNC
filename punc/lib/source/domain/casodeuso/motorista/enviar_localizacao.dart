import '../../../data/modelos/motorista.dart';
import '../../../data/repositorios/repositorio_motorista.dart';

/// RF08 — Caso de uso "Transmitir localização automaticamente".
class EnviarLocalizacaoMotorista {
  EnviarLocalizacaoMotorista({RepositorioMotorista? repositorio})
      : _repositorio = repositorio ?? RepositorioMotorista();

  final RepositorioMotorista _repositorio;

  Future<LocalizacaoMotorista> executar({
    required int idMotorista,
    required String mac,
    required double latitude,
    required double longitude,
  }) {
    return _repositorio.enviarLocalizacao(
      idMotorista: idMotorista,
      mac: mac,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
