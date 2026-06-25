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

  LocalizacaoUsuario copyWith({
    double? latitude,
    double? longitude,
    String? descricao,
    String? cep,
  }) {
    return LocalizacaoUsuario(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descricao: descricao ?? this.descricao,
      cep: cep ?? this.cep,
    );
  }
}
