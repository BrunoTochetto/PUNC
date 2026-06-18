class PerfilUsuario {
  const PerfilUsuario({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.modoEscuro,
    required this.idioma,
    required this.notificacaoEmail,
  });

  final String nome;
  final String email;
  final String telefone;
  final bool modoEscuro;
  final String idioma;
  final bool notificacaoEmail;
}
