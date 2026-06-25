import '../api_client.dart';
import '../modelos/horario_coleta.dart';

/// Repositório de horários de coleta.
class RepositorioHorarioColeta {
  RepositorioHorarioColeta({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  /// GET /api/horariosColeta/:cep
  Future<List<HorarioColeta>> listarPorCep(String cep) async {
    final resposta = await _client.get('/api/horariosColeta/$cep');
    return _extrairHorarios(resposta);
  }
  /// GET /api/horariosColeta/gerente/
  Future<List<HorarioColeta>> listarPorGerente({
    required int idGerente,
  }) async {
    final resposta = await _client.get(
      '/api/horariosColeta/gerente/',
      corpo: {'id_gerente': idGerente},
    );

    final lista = resposta['horarios'] as List<dynamic>?;
    if (lista != null) {
      return lista
          .map(
            (item) => HorarioColeta.fromMap(item as Map<dynamic, dynamic>),
          )
          .toList();
    }

    return _extrairHorarios(resposta);
  }

  /// POST /api/horariosColeta/
  Future<HorarioColeta> criar({
    required int idGerente,
    required int idAreaAtuacao,
    required String horarioEstimado,
    required String diaSemana,
    required String tipoLixo,
    String? comentarios,
  }) async {
    final resposta = await _client.post(
      '/api/horariosColeta/',
      corpo: {
        'id_gerente': idGerente,
        'id_area_atuacao': idAreaAtuacao,
        'horario_estimado': horarioEstimado,
        'dia_semana': diaSemana,
        'tipo_lixo': tipoLixo,
        'comentarios': ?comentarios,
      },
    );

    return HorarioColeta.fromJson(resposta['horario'] as Map<String, dynamic>);
  }

  /// PUT /api/horariosColeta/
  Future<HorarioColeta> editar({
    required int idGerente,
    required int idHorario,
    int? idAreaAtuacao,
    String? horarioEstimado,
    String? diaSemana,
    String? tipoLixo,
    String? comentarios,
    bool? ativo,
  }) async {
    final resposta = await _client.put(
      '/api/horariosColeta/',
      corpo: {
        'id_gerente': idGerente,
        'id_horario': idHorario,
        'id_area_atuacao': ?idAreaAtuacao,
        'horario_estimado': ?horarioEstimado,
        'dia_semana': ?diaSemana,
        'tipo_lixo': ?tipoLixo,
        'comentarios': ?comentarios,
        'ativo': ?ativo,
      },
    );

    return HorarioColeta.fromJson(resposta['horario'] as Map<String, dynamic>);
  }

  /// O back-end espalha arrays como chaves numéricas em alguns endpoints.
  List<HorarioColeta> _extrairHorarios(Map<String, dynamic> resposta) {
    if (resposta['horarios'] is List) {
      return (resposta['horarios'] as List)
          .map(
            (item) => HorarioColeta.fromMap(item as Map<dynamic, dynamic>),
          )
          .toList();
    }

    return resposta.entries
        .where((entry) => int.tryParse(entry.key) != null)
        .map(
          (entry) =>
              HorarioColeta.fromMap(entry.value as Map<dynamic, dynamic>),
        )
        .toList();
  }
}
