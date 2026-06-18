class CelulaUsuario {
  CelulaUsuario({required this.x, required this.y, required this.topico});

  final int? x;
  final int? y;
  final String? topico;

  factory CelulaUsuario.fromJson(Map<String, dynamic> json) {
    return CelulaUsuario(
      x: _lerInt(json['x']),
      y: _lerInt(json['y']),
      topico: json['topico'] as String?,
    );
  }
}

class UsuarioCadastrado {
  UsuarioCadastrado({
    required this.id,
    required this.idCelula,
    required this.idRegiao,
    required this.celula,
    this.inscricaoFcm,
  });

  final int id;
  final int? idCelula;
  final int? idRegiao;
  final CelulaUsuario celula;
  final InscricaoFcmBackend? inscricaoFcm;

  factory UsuarioCadastrado.fromJson(Map<String, dynamic> json) {
    return UsuarioCadastrado(
      id: _lerInt(json['id']) ?? 0,
      idCelula: _lerInt(json['id_celula']),
      idRegiao: _lerInt(json['id_regiao']),
      celula: CelulaUsuario.fromJson(
        (json['celula'] as Map<String, dynamic>?) ?? {},
      ),
      inscricaoFcm: json['inscricao_fcm'] is Map<String, dynamic>
          ? InscricaoFcmBackend.fromJson(
              json['inscricao_fcm'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class InscricaoFcmBackend {
  InscricaoFcmBackend({
    required this.inscrito,
    this.topico,
    this.motivo,
    this.erro,
    this.sucesso,
    this.falhas,
  });

  final bool inscrito;
  final String? topico;
  final String? motivo;
  final String? erro;
  final int? sucesso;
  final int? falhas;

  factory InscricaoFcmBackend.fromJson(Map<String, dynamic> json) {
    return InscricaoFcmBackend(
      inscrito: json['inscrito'] == true,
      topico: json['topico']?.toString(),
      motivo: json['motivo']?.toString(),
      erro: json['erro']?.toString(),
      sucesso: _lerInt(json['sucesso']),
      falhas: _lerInt(json['falhas']),
    );
  }
}

int? _lerInt(dynamic valor) {
  if (valor == null) {
    return null;
  }
  if (valor is int) {
    return valor;
  }
  return int.tryParse(valor.toString());
}

class ResultadoCadastroUsuario {
  ResultadoCadastroUsuario({
    required this.mensagem,
    required this.usuario,
  });

  final String mensagem;
  final UsuarioCadastrado usuario;

  factory ResultadoCadastroUsuario.fromJson(Map<String, dynamic> json) {
    return ResultadoCadastroUsuario(
      mensagem: json['mensagem']?.toString() ?? '',
      usuario: UsuarioCadastrado.fromJson(
        json['usuario'] as Map<String, dynamic>,
      ),
    );
  }
}
