import '../../../data/modelos/horario_coleta.dart';
import '../../../data/repositorios/repositorio_horario_coleta.dart';

/// RF09 — Caso de uso "Cadastrar horários de coleta".
class CadastrarHorarioColeta {
  CadastrarHorarioColeta({RepositorioHorarioColeta? repositorio})
      : _repositorio = repositorio ?? RepositorioHorarioColeta();

  final RepositorioHorarioColeta _repositorio;

  Future<HorarioColeta> executar({
    required int idGerente,
    required int idAreaAtuacao,
    required String horarioEstimado,
    required String diaSemana,
    required String tipoLixo,
    String? comentarios,
  }) {
    return _repositorio.criar(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao,
      horarioEstimado: horarioEstimado,
      diaSemana: diaSemana,
      tipoLixo: tipoLixo,
      comentarios: comentarios,
    );
  }
}
