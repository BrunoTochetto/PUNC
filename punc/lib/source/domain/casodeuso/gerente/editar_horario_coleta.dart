import '../../../data/modelos/horario_coleta.dart';
import '../../../data/repositorios/repositorio_horario_coleta.dart';

/// Caso de uso "Editar horários de coleta" e "Remover horários de coleta"
/// (desativação via campo [ativo] = false).
class EditarHorarioColeta {
  EditarHorarioColeta({RepositorioHorarioColeta? repositorio})
      : _repositorio = repositorio ?? RepositorioHorarioColeta();

  final RepositorioHorarioColeta _repositorio;

  Future<HorarioColeta> executar({
    required int idGerente,
    required int idHorario,
    int? idAreaAtuacao,
    String? horarioEstimado,
    String? diaSemana,
    String? tipoLixo,
    String? comentarios,
    bool? ativo,
  }) {
    return _repositorio.editar(
      idGerente: idGerente,
      idHorario: idHorario,
      idAreaAtuacao: idAreaAtuacao,
      horarioEstimado: horarioEstimado,
      diaSemana: diaSemana,
      tipoLixo: tipoLixo,
      comentarios: comentarios,
      ativo: ativo,
    );
  }

  Future<HorarioColeta> desativar({
    required int idGerente,
    required int idHorario,
  }) {
    return executar(
      idGerente: idGerente,
      idHorario: idHorario,
      ativo: false,
    );
  }
}
