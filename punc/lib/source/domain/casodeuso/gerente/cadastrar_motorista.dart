import '../../../data/modelos/gerente.dart';
import '../../../data/repositorios/repositorio_gerente.dart';

/// RF12 — Caso de uso "Cadastrar caminhão/motorista".
class CadastrarMotorista {
  CadastrarMotorista({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<MotoristaGerente> executar({
    required int idGerente,
    required String nomeDispositivo,
    required String mac,
  }) {
    if (nomeDispositivo.trim().isEmpty || mac.trim().isEmpty) {
      throw ArgumentError('Nome do dispositivo e MAC são obrigatórios.');
    }

    return _repositorio.cadastrarMotorista(
      idGerente: idGerente,
      nomeDispositivo: nomeDispositivo.trim(),
      mac: mac.trim(),
    );
  }
}
