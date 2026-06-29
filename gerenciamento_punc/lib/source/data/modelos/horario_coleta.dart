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
      idHorario: (json['id_horario'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt(),
      horarioEstimado: json['horario_estimado']?.toString() ?? '',
      diaSemana: json['dia_semana']?.toString() ?? '',
      tipoLixo: json['tipo_lixo']?.toString() ?? '',
      comentarios: json['comentarios']?.toString(),
      ativo: _lerBool(json['ativo']),
      idAreaAtuacao: (json['id_area_atuacao'] as num?)?.toInt(),
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

  List<String> get diasSemanaLista => parseDias(diaSemana);

  static List<String> parseDias(String? valor) {
    if (valor == null || valor.trim().isEmpty) return [];

    return valor
        .split(',')
        .map((dia) => dia.trim())
        .where((dia) => dia.isNotEmpty)
        .toList();
  }

  static String formatarDias(Iterable<String> dias) {
    return dias.map((dia) => dia.trim()).where((dia) => dia.isNotEmpty).join(', ');
  }

  String chaveAgrupamento() {
    return [
      horarioEstimado,
      tipoLixo,
      idAreaAtuacao,
      cep,
      comentarios,
      ativo,
    ].join('|');
  }
}

/// Agrupa horários equivalentes (mesmo horário, área, tipo etc.) em um único tópico.
class HorarioColetaGrupo {
  HorarioColetaGrupo({required this.registros})
      : assert(registros.isNotEmpty, 'Grupo precisa de ao menos um registro');

  final List<HorarioColeta> registros;

  HorarioColeta get principal => registros.first;

  List<int> get idsHorario {
    return registros
        .map((registro) => registro.idHorario)
        .whereType<int>()
        .toList();
  }

  List<String> get diasSemana {
    if (registros.length == 1) {
      return registros.first.diasSemanaLista;
    }

    return registros.map((registro) => registro.diaSemana).toList();
  }

  String get diasFormatados => HorarioColeta.formatarDias(diasSemana);

  String get horarioEstimado => principal.horarioEstimado;

  String get tipoLixo => principal.tipoLixo;

  String? get comentarios => principal.comentarios;

  bool? get ativo => principal.ativo;

  int? get idAreaAtuacao => principal.idAreaAtuacao;

  String? get cep => principal.cep;

  static List<HorarioColetaGrupo> agrupar(List<HorarioColeta> horarios) {
    final grupos = <String, List<HorarioColeta>>{};

    for (final horario in horarios) {
      if (horario.diasSemanaLista.length > 1) {
        grupos['id:${horario.idHorario}'] = [horario];
        continue;
      }

      final chave = horario.chaveAgrupamento();
      grupos.putIfAbsent(chave, () => []).add(horario);
    }

    return grupos.values
        .map((registros) => HorarioColetaGrupo(registros: registros))
        .toList();
  }
}
