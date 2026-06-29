import '../../data/modelos/trajetoria.dart';
import '../../data/repositorios/repositorio_gerente.dart';

class ListarTrajetoriasGerente {
  ListarTrajetoriasGerente({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<List<TrajetoriaGerente>> executar({required int idGerente}) {
    return _repositorio.listarTrajetorias(idGerente: idGerente);
  }
}
