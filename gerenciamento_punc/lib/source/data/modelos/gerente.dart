class SessaoGerente {
  SessaoGerente({
    required this.id,
    required this.nome,
    required this.token,
    required this.mensagem,
  });

  final int id;
  final String nome;
  final String token;
  final String mensagem;

  factory SessaoGerente.fromJson(Map<String, dynamic> json) {
    return SessaoGerente(
      id: (json['id'] as num).toInt(),
      nome: json['nome']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      mensagem: json['mensagem']?.toString() ?? '',
    );
  }
}

class MotoristaGerente {
  MotoristaGerente({
    required this.idMotorista,
    required this.nomeDispositivo,
    required this.mac,
    this.identificacaoCaminhao,
    this.tipoLixo,
    this.idGerente,
    this.dataCriacao,
    this.status,
  });

  final int idMotorista;
  final String nomeDispositivo;
  final String mac;
  final String? identificacaoCaminhao;
  final String? tipoLixo;
  final int? idGerente;
  final String? dataCriacao;
  final String? status;

  factory MotoristaGerente.fromJson(Map<String, dynamic> json) {
    return MotoristaGerente(
      idMotorista: ((json['id_motorista'] ?? json['id']) as num).toInt(),
      nomeDispositivo: json['nome_dispositivo']?.toString() ??
          json['nome_motorista']?.toString() ??
          '',
      mac: json['mac']?.toString() ?? '',
      identificacaoCaminhao: json['identificacao_caminhao']?.toString(),
      tipoLixo: json['tipo_lixo']?.toString(),
      idGerente: (json['id_gerente'] as num?)?.toInt(),
      dataCriacao: json['data_criacao']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class AreaAtuacao {
  AreaAtuacao({
    required this.id,
    required this.idGerente,
    required this.cep,
  });

  final int id;
  final int idGerente;
  final String cep;

  factory AreaAtuacao.fromJson(Map<String, dynamic> json) {
    return AreaAtuacao(
      id: (json['id'] as num).toInt(),
      idGerente: (json['id_gerente'] as num?)?.toInt() ?? 0,
      cep: json['cep']?.toString() ?? '',
    );
  }
}
