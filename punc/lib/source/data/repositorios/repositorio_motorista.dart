import '../api_client.dart';
import '../modelos/gerente.dart';
import '../modelos/motorista.dart';

/// Repositório de dados dos motoristas (dispositivos dos caminhões).
class RepositorioMotorista {
  RepositorioMotorista({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  /// GET /api/motorista/ativos
  Future<List<MotoristaGerente>> listarAtivos({
    required int idGerente,
  }) async {
    final resposta = await _client.get(
      '/api/motorista/ativos',
      corpo: {'id_gerente': idGerente},
    );

    final lista = resposta['motoristas'] as List<dynamic>? ?? [];
    return lista
        .map((item) => MotoristaGerente.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/motorista/:id/status
  Future<ResultadoStatusMotorista> atualizarStatus({
    required int idMotorista,
    required String status,
  }) async {
    final resposta = await _client.patch(
      '/api/motorista/$idMotorista/status',
      corpo: {'status': status},
    );

    return ResultadoStatusMotorista.fromJson(resposta);
  }

  /// POST /api/motorista/:id/localizacao
  Future<LocalizacaoMotorista> enviarLocalizacao({
    required int idMotorista,
    required String mac,
    required double latitude,
    required double longitude,
  }) async {
    final resposta = await _client.post(
      '/api/motorista/$idMotorista/localizacao',
      corpo: {
        'mac': mac,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return LocalizacaoMotorista.fromJson(
      resposta['localizacao'] as Map<String, dynamic>,
    );
  }

  /// PATCH /api/motorista/acharTodosEmRaio
  Future<List<LocalizacaoMotorista>> buscarEmRaio({
    required double latitude,
    required double longitude,
    double raioMetros = 1000,
  }) async {
    final resposta = await _client.patch(
      '/api/motorista/acharTodosEmRaio',
      corpo: {
        'latitude': latitude,
        'longitude': longitude,
        'raioM': raioMetros,
      },
    );

    final lista = resposta['localizacoes'] as List<dynamic>? ?? [];
    return lista
        .map((item) => LocalizacaoMotorista.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
