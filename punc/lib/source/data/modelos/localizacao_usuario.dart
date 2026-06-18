class LocalizacaoUsuario {
  const LocalizacaoUsuario({
    required this.latitude,
    required this.longitude,
    required this.descricao,
    required this.cep,
  });

  final double latitude;
  final double longitude;
  final String descricao;
  final String cep;
}
