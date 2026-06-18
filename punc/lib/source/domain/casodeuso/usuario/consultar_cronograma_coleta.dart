import '../../../data/modelos/horario_coleta.dart';
import '../../../data/repositorios/repositorio_horario_coleta.dart';

/// Caso de uso "Consultar cronograma de coleta" (usuário padrão).
/// GET /api/horariosColeta/:cep
class ConsultarCronogramaColeta {
  ConsultarCronogramaColeta({RepositorioHorarioColeta? repositorio})
      : _repositorio = repositorio ?? RepositorioHorarioColeta();

  final RepositorioHorarioColeta _repositorio;

  Future<List<HorarioColeta>> executar({required String cep}) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) {
      throw ArgumentError('CEP deve conter 8 dígitos.');
    }

    return _repositorio.listarPorCep(cepLimpo);
  }
}
