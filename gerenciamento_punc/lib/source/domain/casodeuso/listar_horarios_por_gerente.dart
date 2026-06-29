import '../../data/modelos/horario_coleta.dart';
import '../../data/repositorios/repositorio_horario_coleta.dart';

/// Lista todos os horários do gerente, incluindo os desativados.
class ListarHorariosPorGerente {
  ListarHorariosPorGerente({RepositorioHorarioColeta? repositorio})
      : _repositorio = repositorio ?? RepositorioHorarioColeta();

  final RepositorioHorarioColeta _repositorio;

  Future<List<HorarioColeta>> executar({required int idGerente}) {
    return _repositorio.listarPorGerente(idGerente: idGerente);
  }
}
