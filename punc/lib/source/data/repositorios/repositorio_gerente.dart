import '../api_client.dart';
import '../modelos/gerente.dart';

/// Repositório de dados do gerente (autenticação e gestão).
class RepositorioGerente {
  RepositorioGerente({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  /// POST /api/gerente/login
  Future<SessaoGerente> login({
    required String email,
    required String senha,
  }) async {
    final resposta = await _client.post(
      '/api/gerente/login',
      corpo: {'email': email, 'senha': senha},
    );

    final sessao = SessaoGerente.fromJson(resposta);
    _client.definirToken(sessao.token);
    return sessao;
  }

  void encerrarSessao() => _client.definirToken(null);

  /// GET /api/gerente/motoristas
  Future<List<MotoristaGerente>> listarMotoristas({
    required int idGerente,
  }) async {
    final resposta = await _client.get(
      '/api/gerente/motoristas',
      corpo: {'id_gerente': idGerente},
    );

    final lista = resposta['motoristas'] as List<dynamic>? ?? [];
    return lista
        .map((item) => MotoristaGerente.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/gerente/motoristas
  Future<MotoristaGerente> cadastrarMotorista({
    required int idGerente,
    required String nomeDispositivo,
    required String mac,
  }) async {
    final resposta = await _client.post(
      '/api/gerente/motoristas',
      corpo: {
        'id_gerente': idGerente,
        'nome_dispositivo': nomeDispositivo,
        'mac': mac,
      },
    );

    return MotoristaGerente.fromJson(
      resposta['motorista'] as Map<String, dynamic>,
    );
  }

  /// DELETE /api/gerente/motoristas/:id
  Future<void> removerMotorista({
    required int idGerente,
    required int idMotorista,
  }) async {
    await _client.delete(
      '/api/gerente/motoristas/$idMotorista',
      corpo: {
        'id_gerente': idGerente,
        'id_motorista': idMotorista,
      },
    );
  }

  /// GET /api/gerente/areaAtuacao
  Future<List<AreaAtuacao>> listarAreasAtuacao({
    required int idGerente,
    String? cep,
  }) async {
    final resposta = await _client.get(
      '/api/gerente/areaAtuacao',
      corpo: {
        'id_gerente': idGerente,
        'cep': cep ?? '',
      },
    );

    final lista = resposta['areas'] as List<dynamic>? ?? [];
    return lista
        .map((item) => AreaAtuacao.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/gerente/areaAtuacao
  Future<AreaAtuacao> cadastrarAreaAtuacao({
    required int idGerente,
    required String cep,
  }) async {
    final resposta = await _client.post(
      '/api/gerente/areaAtuacao',
      corpo: {
        'id_gerente': idGerente,
        'cep': cep,
      },
    );

    return AreaAtuacao.fromJson(resposta['area'] as Map<String, dynamic>);
  }

  /// DELETE /api/gerente/areaAtuacao/:id
  Future<void> removerAreaAtuacao({
    required int idGerente,
    required int idAreaAtuacao,
  }) async {
    await _client.delete(
      '/api/gerente/areaAtuacao/$idAreaAtuacao',
      corpo: {
        'id_gerente': idGerente,
        'id_area_atuacao': idAreaAtuacao,
      },
    );
  }
}
