import '../domain/casodeuso/cadastrar_motorista.dart';
import '../domain/casodeuso/listar_motoristas.dart';
import '../domain/casodeuso/remover_motorista.dart';
import '../data/modelos/gerente.dart';

class CaminhoesViewModel {
  CaminhoesViewModel({
    ListarMotoristasGerente? listarMotoristas,
    CadastrarMotorista? cadastrarMotorista,
    RemoverMotorista? removerMotorista,
  })  : _listarMotoristas = listarMotoristas ?? ListarMotoristasGerente(),
        _cadastrarMotorista = cadastrarMotorista ?? CadastrarMotorista(),
        _removerMotorista = removerMotorista ?? RemoverMotorista();

  final ListarMotoristasGerente _listarMotoristas;
  final CadastrarMotorista _cadastrarMotorista;
  final RemoverMotorista _removerMotorista;

  Future<List<MotoristaGerente>> listar({required int idGerente}) {
    return _listarMotoristas.executar(idGerente: idGerente);
  }

  Future<MotoristaGerente> cadastrar({
    required int idGerente,
    required String mac,
  }) {
    return _cadastrarMotorista.executar(
      idGerente: idGerente,
      nomeDispositivo: mac,
      mac: mac,
    );
  }

  Future<void> remover({
    required int idGerente,
    required int idMotorista,
  }) {
    return _removerMotorista.executar(
      idGerente: idGerente,
      idMotorista: idMotorista,
    );
  }
}
