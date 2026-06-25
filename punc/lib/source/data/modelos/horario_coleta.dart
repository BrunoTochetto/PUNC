class HorarioColeta {
  HorarioColeta({
    this.idHorario,
    required this.horarioEstimado,
    required this.diaSemana,
    required this.tipoLixo,
    this.comentarios,
    this.ativo,
    this.idAreaAtuacao,
    this.cep,
    this.dataCriacao,
  });

  final int? idHorario;
  final String horarioEstimado;
  final String diaSemana;
  final String tipoLixo;
  final String? comentarios;
  final bool? ativo;
  final int? idAreaAtuacao;
  final String? cep;
  final String? dataCriacao;

  factory HorarioColeta.fromJson(Map<String, dynamic> json) {
    return HorarioColeta(
      idHorario: json['id_horario'] as int? ?? json['id'] as int?,
      horarioEstimado: json['horario_estimado']?.toString() ?? '',
      diaSemana: json['dia_semana']?.toString() ?? '',
      tipoLixo: json['tipo_lixo']?.toString() ?? '',
      comentarios: json['comentarios']?.toString(),
      ativo: _lerBool(json['ativo']),
      idAreaAtuacao: json['id_area_atuacao'] as int?,
      cep: json['cep']?.toString() ?? json['cep_area']?.toString(),
      dataCriacao: json['data_criacao']?.toString(),
    );
  }

  static HorarioColeta fromMap(Map<dynamic, dynamic> json) {
    return HorarioColeta.fromJson(Map<String, dynamic>.from(json));
  }

  static bool? _lerBool(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      final normalizado = valor.toLowerCase();
      if (normalizado == 'true' || normalizado == 't' || normalizado == '1') {
        return true;
      }
      if (normalizado == 'false' || normalizado == 'f' || normalizado == '0') {
        return false;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (idHorario != null) 'id_horario': idHorario,
      'horario_estimado': horarioEstimado,
      'dia_semana': diaSemana,
      'tipo_lixo': tipoLixo,
      if (comentarios != null) 'comentarios': comentarios,
      if (ativo != null) 'ativo': ativo,
      if (idAreaAtuacao != null) 'id_area_atuacao': idAreaAtuacao,
      if (cep != null) 'cep': cep,
      if (dataCriacao != null) 'data_criacao': dataCriacao,
    };
  }
}
