import '../data/modelos/gerente.dart';
import '../domain/casodeuso/gerente/listar_motoristas.dart';
import '../domain/casodeuso/gerente/remover_motorista.dart';

class GerenciamentoViewModel {
  GerenciamentoViewModel({
    ListarMotoristasGerente? listarMotoristas,
    RemoverMotorista? removerMotorista,
  })  : _listarMotoristas = listarMotoristas ?? ListarMotoristasGerente(),
        _removerMotorista = removerMotorista ?? RemoverMotorista();

  final ListarMotoristasGerente _listarMotoristas;
  final RemoverMotorista _removerMotorista;

  Future<List<MotoristaGerente>> carregarMotoristas({required int idGerente}) {
    return _listarMotoristas.executar(idGerente: idGerente);
  }

  Future<void> excluirMotorista({
    required int idGerente,
    required int idMotorista,
  }) {
    return _removerMotorista.executar(
      idGerente: idGerente,
      idMotorista: idMotorista,
    );
  }
}
