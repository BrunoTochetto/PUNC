import '../domain/casodeuso/cadastrar_area_atuacao.dart';
import '../domain/casodeuso/listar_areas_atuacao.dart';
import '../domain/casodeuso/remover_area_atuacao.dart';
import '../data/modelos/gerente.dart';

class AreasAtuacaoViewModel {
  AreasAtuacaoViewModel({
    ListarAreasAtuacao? listarAreas,
    CadastrarAreaAtuacao? cadastrarArea,
    RemoverAreaAtuacao? removerArea,
  })  : _listarAreas = listarAreas ?? ListarAreasAtuacao(),
        _cadastrarArea = cadastrarArea ?? CadastrarAreaAtuacao(),
        _removerArea = removerArea ?? RemoverAreaAtuacao();

  final ListarAreasAtuacao _listarAreas;
  final CadastrarAreaAtuacao _cadastrarArea;
  final RemoverAreaAtuacao _removerArea;

  Future<List<AreaAtuacao>> listar({required int idGerente}) {
    return _listarAreas.executar(idGerente: idGerente);
  }

  Future<AreaAtuacao> cadastrar({
    required int idGerente,
    required String cep,
  }) {
    return _cadastrarArea.executar(idGerente: idGerente, cep: cep);
  }

  Future<void> remover({
    required int idGerente,
    required int idAreaAtuacao,
  }) {
    return _removerArea.executar(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao,
    );
  }
}
