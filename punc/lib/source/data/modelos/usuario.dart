class CelulaUsuario {
  CelulaUsuario({required this.x, required this.y});

  final int? x;
  final int? y;

  factory CelulaUsuario.fromJson(Map<String, dynamic> json) {
    return CelulaUsuario(
      x: json['x'] as int?,
      y: json['y'] as int?,
    );
  }
}

class UsuarioCadastrado {
  UsuarioCadastrado({
    required this.id,
    required this.idCelula,
    required this.idRegiao,
    required this.celula,
  });

  final int id;
  final int? idCelula;
  final int? idRegiao;
  final CelulaUsuario celula;

  factory UsuarioCadastrado.fromJson(Map<String, dynamic> json) {
    return UsuarioCadastrado(
      id: json['id'] as int,
      idCelula: json['id_celula'] as int?,
      idRegiao: json['id_regiao'] as int?,
      celula: CelulaUsuario.fromJson(
        (json['celula'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
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
