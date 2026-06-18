import '../api_client.dart';
import '../modelos/usuario.dart';

/// Repositório de dados do usuário padrão (cidadão).
class RepositorioUsuario {
  RepositorioUsuario({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  /// POST /api/usuario/cadastro
  Future<ResultadoCadastroUsuario> cadastrar({
    required String nomeDispositivo,
    required String mac,
    required double latitude,
    required double longitude,
  }) async {
    final resposta = await _client.post(
      '/api/usuario/cadastro',
      corpo: {
        'nome_dispositivo': nomeDispositivo,
        'mac': mac,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return ResultadoCadastroUsuario.fromJson(resposta);
  }
}
