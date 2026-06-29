import '../domain/casodeuso/listar_localizacoes_trajetoria.dart';
import '../domain/casodeuso/listar_trajetorias_gerente.dart';
import '../data/modelos/trajetoria.dart';

class RotasViewModel {
  RotasViewModel({
    ListarTrajetoriasGerente? listarTrajetorias,
    ListarLocalizacoesTrajetoria? listarLocalizacoes,
  })  : _listarTrajetorias = listarTrajetorias ?? ListarTrajetoriasGerente(),
        _listarLocalizacoes = listarLocalizacoes ?? ListarLocalizacoesTrajetoria();

  final ListarTrajetoriasGerente _listarTrajetorias;
  final ListarLocalizacoesTrajetoria _listarLocalizacoes;

  Future<List<TrajetoriaGerente>> listar({required int idGerente}) {
    return _listarTrajetorias.executar(idGerente: idGerente);
  }

  Future<List<LocalizacaoTrajetoria>> listarLocalizacoes({
    required int idGerente,
    required int idTrajetoria,
  }) {
    return _listarLocalizacoes.executar(
      idGerente: idGerente,
      idTrajetoria: idTrajetoria,
    );
  }
}
