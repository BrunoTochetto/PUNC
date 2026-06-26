class Falha {
  const Falha(this.mensagem);

  final String mensagem;
}

class BackendFalha extends Falha {
  const BackendFalha(super.mensagem);
}

class LocalizacaoFalha extends Falha {
  const LocalizacaoFalha(super.mensagem);
}

class NotificacaoFalha extends Falha {
  const NotificacaoFalha(super.mensagem);
}
