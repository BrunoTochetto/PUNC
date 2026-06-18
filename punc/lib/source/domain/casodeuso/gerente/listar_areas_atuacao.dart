import '../../../data/modelos/gerente.dart';
import '../../../data/repositorios/repositorio_gerente.dart';

/// Lista as áreas de atuação (grupos por CEP) do gerente.
class ListarAreasAtuacao {
  ListarAreasAtuacao({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<List<AreaAtuacao>> executar({
    required int idGerente,
    String? cep,
  }) {
    return _repositorio.listarAreasAtuacao(
      idGerente: idGerente,
      cep: cep,
    );
  }
}
