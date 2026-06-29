import '../../data/modelos/gerente.dart';
import '../../data/repositorios/repositorio_gerente.dart';

/// Caso de uso "Consultar/listar caminhões" (gerente).
class ListarMotoristasGerente {
  ListarMotoristasGerente({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<List<MotoristaGerente>> executar({required int idGerente}) {
    return _repositorio.listarMotoristas(idGerente: idGerente);
  }
}
