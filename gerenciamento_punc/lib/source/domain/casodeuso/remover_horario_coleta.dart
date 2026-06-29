import '../../data/repositorios/repositorio_horario_coleta.dart';

class RemoverHorarioColeta {
  RemoverHorarioColeta({RepositorioHorarioColeta? repositorio})
      : _repositorio = repositorio ?? RepositorioHorarioColeta();

  final RepositorioHorarioColeta _repositorio;

  Future<void> executar({
    required int idGerente,
    required int idHorario,
  }) {
    return _repositorio.remover(
      idGerente: idGerente,
      idHorario: idHorario,
    );
  }
}
