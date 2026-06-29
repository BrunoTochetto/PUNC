import '../domain/casodeuso/cadastrar_horario_coleta.dart';
import '../domain/casodeuso/editar_horario_coleta.dart';
import '../domain/casodeuso/listar_areas_atuacao.dart';
import '../domain/casodeuso/listar_horarios_por_gerente.dart';
import '../domain/casodeuso/remover_horario_coleta.dart';
import '../data/modelos/gerente.dart';
import '../data/modelos/horario_coleta.dart';

class HorariosColetaViewModel {
  HorariosColetaViewModel({
    ListarHorariosPorGerente? listarHorarios,
    ListarAreasAtuacao? listarAreas,
    CadastrarHorarioColeta? cadastrarHorario,
    EditarHorarioColeta? editarHorario,
    RemoverHorarioColeta? removerHorario,
  })  : _listarHorarios = listarHorarios ?? ListarHorariosPorGerente(),
        _listarAreas = listarAreas ?? ListarAreasAtuacao(),
        _cadastrarHorario = cadastrarHorario ?? CadastrarHorarioColeta(),
        _editarHorario = editarHorario ?? EditarHorarioColeta(),
        _removerHorario = removerHorario ?? RemoverHorarioColeta();

  final ListarHorariosPorGerente _listarHorarios;
  final ListarAreasAtuacao _listarAreas;
  final CadastrarHorarioColeta _cadastrarHorario;
  final EditarHorarioColeta _editarHorario;
  final RemoverHorarioColeta _removerHorario;

  Future<List<HorarioColeta>> listar({required int idGerente}) {
    return _listarHorarios.executar(idGerente: idGerente);
  }

  Future<List<AreaAtuacao>> listarAreas({required int idGerente}) {
    return _listarAreas.executar(idGerente: idGerente);
  }

  Future<HorarioColeta> cadastrar({
    required int idGerente,
    required int idAreaAtuacao,
    required String horarioEstimado,
    required String diaSemana,
    required String tipoLixo,
    String? comentarios,
  }) {
    return _cadastrarHorario.executar(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao,
      horarioEstimado: horarioEstimado,
      diaSemana: diaSemana,
      tipoLixo: tipoLixo,
      comentarios: comentarios,
    );
  }

  Future<List<HorarioColetaGrupo>> listarAgrupados({required int idGerente}) async {
    final horarios = await listar(idGerente: idGerente);
    return HorarioColetaGrupo.agrupar(horarios);
  }

  Future<HorarioColeta> cadastrarVarios({
    required int idGerente,
    required int idAreaAtuacao,
    required String horarioEstimado,
    required List<String> diasSemana,
    required String tipoLixo,
    String? comentarios,
  }) {
    return cadastrar(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao,
      horarioEstimado: horarioEstimado,
      diaSemana: HorarioColeta.formatarDias(diasSemana),
      tipoLixo: tipoLixo,
      comentarios: comentarios,
    );
  }

  Future<void> excluirGrupo({
    required int idGerente,
    required HorarioColetaGrupo grupo,
  }) async {
    for (final idHorario in grupo.idsHorario) {
      await excluir(idGerente: idGerente, idHorario: idHorario);
    }
  }

  Future<void> editarGrupo({
    required int idGerente,
    required HorarioColetaGrupo grupo,
    int? idAreaAtuacao,
    required String horarioEstimado,
    required List<String> diasSemana,
    required String tipoLixo,
    String? comentarios,
    bool? ativo,
  }) async {
    final diasFormatados = HorarioColeta.formatarDias(diasSemana);

    if (grupo.registros.length == 1 && grupo.idsHorario.length == 1) {
      await editar(
        idGerente: idGerente,
        idHorario: grupo.idsHorario.first,
        idAreaAtuacao: idAreaAtuacao,
        horarioEstimado: horarioEstimado,
        diaSemana: diasFormatados,
        tipoLixo: tipoLixo,
        comentarios: comentarios,
        ativo: ativo,
      );
      return;
    }

    for (final idHorario in grupo.idsHorario) {
      await excluir(idGerente: idGerente, idHorario: idHorario);
    }

    final criado = await cadastrar(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao ?? grupo.idAreaAtuacao!,
      horarioEstimado: horarioEstimado,
      diaSemana: diasFormatados,
      tipoLixo: tipoLixo,
      comentarios: comentarios,
    );

    if (ativo == false && criado.idHorario != null) {
      await editar(
        idGerente: idGerente,
        idHorario: criado.idHorario!,
        ativo: false,
      );
    }
  }

  Future<HorarioColeta> editar({
    required int idGerente,
    required int idHorario,
    int? idAreaAtuacao,
    String? horarioEstimado,
    String? diaSemana,
    String? tipoLixo,
    String? comentarios,
    bool? ativo,
  }) {
    return _editarHorario.executar(
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

  Future<void> excluir({
    required int idGerente,
    required int idHorario,
  }) {
    return _removerHorario.executar(
      idGerente: idGerente,
      idHorario: idHorario,
    );
  }

  Future<HorarioColeta> desativar({
    required int idGerente,
    required int idHorario,
  }) {
    return _editarHorario.desativar(
      idGerente: idGerente,
      idHorario: idHorario,
    );
  }
}
