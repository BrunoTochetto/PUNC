import '../../../data/modelos/motorista.dart';
import '../../../data/repositorios/repositorio_motorista.dart';

/// Busca caminhões em operação dentro de um raio da residência do usuário.
class BuscarMotoristasEmRaio {
  BuscarMotoristasEmRaio({RepositorioMotorista? repositorio})
      : _repositorio = repositorio ?? RepositorioMotorista();

  final RepositorioMotorista _repositorio;

  Future<List<LocalizacaoMotorista>> executar({
    required double latitude,
    required double longitude,
    double raioMetros = 1000,
  }) {
    return _repositorio.buscarEmRaio(
      latitude: latitude,
      longitude: longitude,
      raioMetros: raioMetros,
    );
  }
}
