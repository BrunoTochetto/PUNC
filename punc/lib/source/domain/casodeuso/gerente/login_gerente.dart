import '../../../data/modelos/gerente.dart';
import '../../../data/repositorios/repositorio_gerente.dart';

/// RF07 — Caso de uso de autenticação do gerente.
class LoginGerente {
  LoginGerente({RepositorioGerente? repositorio})
      : _repositorio = repositorio ?? RepositorioGerente();

  final RepositorioGerente _repositorio;

  Future<SessaoGerente> executar({
    required String email,
    required String senha,
  }) {
    if (email.trim().isEmpty || senha.isEmpty) {
      throw ArgumentError('E-mail e senha são obrigatórios.');
    }

    return _repositorio.login(
      email: email.trim().toLowerCase(),
      senha: senha,
    );
  }
}
