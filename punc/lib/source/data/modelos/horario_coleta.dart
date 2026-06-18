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
      ativo: json['ativo'] as bool?,
      idAreaAtuacao: json['id_area_atuacao'] as int?,
      cep: json['cep']?.toString(),
      dataCriacao: json['data_criacao']?.toString(),
    );
  }
}
