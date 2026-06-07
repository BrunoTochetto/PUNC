import '../../../data/modelos/motorista.dart';
import '../../../data/repositorios/repositorio_motorista.dart';

/// RF06/RF13/RF14 — Caso de uso "Atualizar status operacional".
/// Valores aceitos pelo back-end: "Em percurso" ou "Inativo".
class AtualizarStatusOperacional {
  AtualizarStatusOperacional({RepositorioMotorista? repositorio})
      : _repositorio = repositorio ?? RepositorioMotorista();

  final RepositorioMotorista _repositorio;

  static const emPercurso = 'Em percurso';
  static const inativo = 'Inativo';

  Future<ResultadoStatusMotorista> executar({
    required int idMotorista,
    required String status,
  }) {
    final statusNormalizado = status.trim();
    if (statusNormalizado != emPercurso && statusNormalizado != inativo) {
      throw ArgumentError('Status deve ser "$emPercurso" ou "$inativo".');
    }

    return _repositorio.atualizarStatus(
      idMotorista: idMotorista,
      status: statusNormalizado,
    );
  }
}
