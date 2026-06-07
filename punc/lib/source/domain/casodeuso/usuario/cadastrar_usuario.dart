import '../../../data/modelos/usuario.dart';
import '../../../data/repositorios/repositorio_usuario.dart';

/// RF01 — Cadastra o usuário padrão com nome do dispositivo e localização inicial.
/// Também cobre o caso de uso "Definir/Atualizar localização de casa".
class CadastrarUsuario {
  CadastrarUsuario({RepositorioUsuario? repositorio})
      : _repositorio = repositorio ?? RepositorioUsuario();

  final RepositorioUsuario _repositorio;

  Future<ResultadoCadastroUsuario> executar({
    required String nomeDispositivo,
    required String mac,
    required double latitude,
    required double longitude,
  }) {
    if (nomeDispositivo.trim().isEmpty) {
      throw ArgumentError('Nome do dispositivo é obrigatório.');
    }
    if (mac.trim().isEmpty) {
      throw ArgumentError('Endereço MAC é obrigatório.');
    }

    return _repositorio.cadastrar(
      nomeDispositivo: nomeDispositivo.trim(),
      mac: mac.trim(),
      latitude: latitude,
      longitude: longitude,
    );
  }
}
