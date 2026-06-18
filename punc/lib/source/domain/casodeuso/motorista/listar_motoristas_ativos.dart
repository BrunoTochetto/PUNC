import '../../../data/modelos/gerente.dart';
import '../../../data/repositorios/repositorio_motorista.dart';

/// RF11 — Lista motoristas com status de percurso para o gerente.
class ListarMotoristasAtivos {
  ListarMotoristasAtivos({RepositorioMotorista? repositorio})
      : _repositorio = repositorio ?? RepositorioMotorista();

  final RepositorioMotorista _repositorio;

  Future<List<MotoristaGerente>> executar({required int idGerente}) {
    return _repositorio.listarAtivos(idGerente: idGerente);
  }
}
