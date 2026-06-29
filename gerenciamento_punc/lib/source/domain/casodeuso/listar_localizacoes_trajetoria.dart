import '../../data/modelos/trajetoria.dart';
import '../../data/repositorios/repositorio_gerente.dart';

class ListarLocalizacoesTrajetoria {
  ListarLocalizacoesTrajetoria({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<List<LocalizacaoTrajetoria>> executar({
    required int idGerente,
    required int idTrajetoria,
  }) {
    return _repositorio.listarLocalizacoesTrajetoria(
      idGerente: idGerente,
      idTrajetoria: idTrajetoria,
    );
  }
}
