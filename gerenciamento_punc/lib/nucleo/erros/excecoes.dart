class AppExcecao implements Exception {
  const AppExcecao(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class BackendExcecao extends AppExcecao {
  const BackendExcecao(super.mensagem);
}

class LocalizacaoExcecao extends AppExcecao {
  const LocalizacaoExcecao(super.mensagem);
}

class NotificacaoExcecao extends AppExcecao {
  const NotificacaoExcecao(super.mensagem);
}
