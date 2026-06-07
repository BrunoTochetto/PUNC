import '../../../data/modelos/gerente.dart';
import '../../../data/repositorios/repositorio_gerente.dart';

/// Cadastra uma nova área de atuação (grupo/região por CEP).
class CadastrarAreaAtuacao {
  CadastrarAreaAtuacao({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<AreaAtuacao> executar({
    required int idGerente,
    required String cep,
  }) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) {
      throw ArgumentError('CEP deve conter 8 dígitos.');
    }

    return _repositorio.cadastrarAreaAtuacao(
      idGerente: idGerente,
      cep: cepLimpo,
    );
  }
}
