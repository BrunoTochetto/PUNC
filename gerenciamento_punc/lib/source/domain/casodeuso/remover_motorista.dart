import '../../data/repositorios/repositorio_gerente.dart';

/// RF12 — Caso de uso "Remover caminhão/motorista".
class RemoverMotorista {
  RemoverMotorista({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<void> executar({
    required int idGerente,
    required int idMotorista,
  }) {
    return _repositorio.removerMotorista(
      idGerente: idGerente,
      idMotorista: idMotorista,
    );
  }
}
