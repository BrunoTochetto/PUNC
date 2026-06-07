class TrajetoriaMotorista {
  TrajetoriaMotorista({
    required this.id,
    required this.idMotorista,
    this.tipoLixo,
    this.tempoComeco,
    this.tempoFim,
  });

  final int id;
  final int idMotorista;
  final String? tipoLixo;
  final String? tempoComeco;
  final String? tempoFim;

  factory TrajetoriaMotorista.fromJson(Map<String, dynamic> json) {
    return TrajetoriaMotorista(
      id: json['id'] as int,
      idMotorista: json['id_motorista'] as int,
      tipoLixo: json['tipo_lixo']?.toString(),
      tempoComeco: json['tempo_comeco']?.toString(),
      tempoFim: json['tempo_fim']?.toString(),
    );
  }
}

class LocalizacaoMotorista {
  LocalizacaoMotorista({
    required this.idLocalizacao,
    required this.idMotorista,
    required this.latitude,
    required this.longitude,
    this.tipoLixo,
    this.identificacaoCaminhao,
    this.idTrajetoria,
    this.idGerente,
    this.tempoComeco,
    this.tempoFim,
  });

  final int? idLocalizacao;
  final int? idMotorista;
  final double latitude;
  final double longitude;
  final String? tipoLixo;
  final String? identificacaoCaminhao;
  final int? idTrajetoria;
  final int? idGerente;
  final String? tempoComeco;
  final String? tempoFim;

  factory LocalizacaoMotorista.fromJson(Map<String, dynamic> json) {
    return LocalizacaoMotorista(
      idLocalizacao: json['id_localizacao'] as int?,
      idMotorista: json['id_motorista'] as int?,
      latitude: _lerCoordenada(json, ['latitude', 'lat']),
      longitude: _lerCoordenada(json, ['longitude', 'lon', 'lng']),
      tipoLixo: json['tipo_lixo']?.toString(),
      identificacaoCaminhao: json['identificacao_caminhao']?.toString(),
      idTrajetoria: json['id_trajetoria'] as int?,
      idGerente: json['id_gerente'] as int?,
      tempoComeco: json['tempo_comeco']?.toString(),
      tempoFim: json['tempo_fim']?.toString(),
    );
  }

  static double _lerCoordenada(
    Map<String, dynamic> json,
    List<String> chaves,
  ) {
    for (final chave in chaves) {
      final valor = json[chave];
      if (valor == null) continue;
      if (valor is num) return valor.toDouble();
      return double.tryParse(valor.toString()) ?? 0;
    }
    return 0;
  }
}

class ResultadoStatusMotorista {
  ResultadoStatusMotorista({
    required this.mensagem,
    required this.trajetoria,
  });

  final String mensagem;
  final TrajetoriaMotorista trajetoria;

  factory ResultadoStatusMotorista.fromJson(Map<String, dynamic> json) {
    return ResultadoStatusMotorista(
      mensagem: json['mensagem']?.toString() ?? '',
      trajetoria: TrajetoriaMotorista.fromJson(
        json['trajetoria'] as Map<String, dynamic>,
      ),
    );
  }
}
