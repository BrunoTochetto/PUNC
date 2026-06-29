class TrajetoriaGerente {
  TrajetoriaGerente({
    required this.idTrajetoria,
    required this.idMotorista,
    required this.nomeMotorista,
    required this.mac,
    this.identificacaoCaminhao,
    this.tipoLixo,
    this.tempoComeco,
    this.tempoFim,
    this.quantidadeLocalizacoes,
  });

  final int idTrajetoria;
  final int idMotorista;
  final String nomeMotorista;
  final String mac;
  final String? identificacaoCaminhao;
  final String? tipoLixo;
  final String? tempoComeco;
  final String? tempoFim;
  final int? quantidadeLocalizacoes;

  bool get emAndamento => tempoFim == null;

  factory TrajetoriaGerente.fromJson(Map<String, dynamic> json) {
    return TrajetoriaGerente(
      idTrajetoria: (json['id_trajetoria'] as num).toInt(),
      idMotorista: (json['id_motorista'] as num).toInt(),
      nomeMotorista: json['nome_motorista']?.toString() ?? '',
      mac: json['mac']?.toString() ?? '',
      identificacaoCaminhao: json['identificacao_caminhao']?.toString(),
      tipoLixo: json['tipo_lixo']?.toString(),
      tempoComeco: json['tempo_comeco']?.toString(),
      tempoFim: json['tempo_fim']?.toString(),
      quantidadeLocalizacoes: _lerInt(json['quantidade_localizacoes']),
    );
  }

  static int? _lerInt(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}

class LocalizacaoTrajetoria {
  LocalizacaoTrajetoria({
    required this.idLocalizacao,
    required this.idTrajetoria,
    required this.latitude,
    required this.longitude,
    this.dataCriacao,
    this.ordem,
  });

  final int idLocalizacao;
  final int idTrajetoria;
  final double latitude;
  final double longitude;
  final String? dataCriacao;
  final int? ordem;

  factory LocalizacaoTrajetoria.fromJson(Map<String, dynamic> json, {int? ordem}) {
    return LocalizacaoTrajetoria(
      idLocalizacao: (json['id_localizacao'] as num).toInt(),
      idTrajetoria: (json['id_trajetoria'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      dataCriacao: json['data_criacao']?.toString(),
      ordem: ordem,
    );
  }
}
