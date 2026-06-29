import 'package:shared_preferences/shared_preferences.dart';

import '../api_client.dart';
import '../modelos/gerente.dart';

/// Persiste e restaura a sessão do gerente autenticado.
class ServicoSessaoGerente {
  ServicoSessaoGerente({ApiClient? client}) : _client = client ?? apiClient;

  static const _chaveId = 'gerente_id';
  static const _chaveNome = 'gerente_nome';
  static const _chaveToken = 'gerente_token';

  final ApiClient _client;

  Future<void> salvar(SessaoGerente sessao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveId, sessao.id);
    await prefs.setString(_chaveNome, sessao.nome);
    await prefs.setString(_chaveToken, sessao.token);
    _client.definirToken(sessao.token);
  }

  Future<SessaoGerente?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_chaveId);
    final nome = prefs.getString(_chaveNome);
    final token = prefs.getString(_chaveToken);

    if (id == null || token == null || token.isEmpty) {
      return null;
    }

    _client.definirToken(token);
    return SessaoGerente(
      id: id,
      nome: nome ?? '',
      token: token,
      mensagem: '',
    );
  }

  Future<void> encerrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveId);
    await prefs.remove(_chaveNome);
    await prefs.remove(_chaveToken);
    _client.definirToken(null);
  }
}

final servicoSessaoGerente = ServicoSessaoGerente();
