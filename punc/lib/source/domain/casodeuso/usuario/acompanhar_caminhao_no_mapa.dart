import '../../../data/modelos/motorista.dart';
import '../../../data/repositorios/repositorio_mapa.dart';

/// RF04/RF05 — Caso de uso "Acompanhar caminhão no mapa".
/// Lista os percursos ativos com a última localização disponível.
class AcompanharCaminhaoNoMapa {
  AcompanharCaminhaoNoMapa({RepositorioMapa? repositorio})
      : _repositorio = repositorio ?? RepositorioMapa();

  final RepositorioMapa _repositorio;

  Future<List<LocalizacaoMotorista>> executar({int? idGerente}) {
    return _repositorio.listarTrajetosEmPercurso(idGerente: idGerente);
  }
}
