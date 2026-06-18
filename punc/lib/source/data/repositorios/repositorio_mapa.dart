import '../api_client.dart';
import '../modelos/motorista.dart';

/// Repositório de dados do mapa em tempo real.
class RepositorioMapa {
  RepositorioMapa({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  /// GET /api/mapa/emPercurso
  Future<List<LocalizacaoMotorista>> listarTrajetosEmPercurso({
    int? idGerente,
  }) async {
    final corpo = idGerente == null ? null : {'id_gerente': idGerente};

    final resposta = await _client.get('/api/mapa/emPercurso', corpo: corpo);

    final lista = resposta['trajetosEmPercurso'] as List<dynamic>? ?? [];
    return lista
        .map((item) => LocalizacaoMotorista.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
