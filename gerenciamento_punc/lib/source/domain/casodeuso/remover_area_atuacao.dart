import '../../data/repositorios/repositorio_gerente.dart';

/// Remove uma área de atuação do gerente.
class RemoverAreaAtuacao {
  RemoverAreaAtuacao({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<void> executar({
    required int idGerente,
    required int idAreaAtuacao,
  }) {
    return _repositorio.removerAreaAtuacao(
      idGerente: idGerente,
      idAreaAtuacao: idAreaAtuacao,
    );
  }
}
