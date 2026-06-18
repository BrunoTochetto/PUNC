import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../nucleo/erros/falha_api.dart';
import '../../nucleo/segredos/api_config.dart';

/// Cliente HTTP centralizado para comunicação com a API REST do back-end.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;
  String? _token;

  void definirToken(String? token) => _token = token;

  String? get token => _token;

  Future<Map<String, dynamic>> get(
    String caminho, {
    Map<String, dynamic>? corpo,
  }) {
    return _requisitar('GET', caminho, corpo: corpo);
  }

  Future<Map<String, dynamic>> post(
    String caminho, {
    Map<String, dynamic>? corpo,
  }) {
    return _requisitar('POST', caminho, corpo: corpo);
  }

  Future<Map<String, dynamic>> put(
    String caminho, {
    Map<String, dynamic>? corpo,
  }) {
    return _requisitar('PUT', caminho, corpo: corpo);
  }

  Future<Map<String, dynamic>> patch(
    String caminho, {
    Map<String, dynamic>? corpo,
  }) {
    return _requisitar('PATCH', caminho, corpo: corpo);
  }

  Future<Map<String, dynamic>> delete(
    String caminho, {
    Map<String, dynamic>? corpo,
  }) {
    return _requisitar('DELETE', caminho, corpo: corpo);
  }

  Future<Map<String, dynamic>> _requisitar(
    String metodo,
    String caminho, {
    Map<String, dynamic>? corpo,
  }) async {
    final uri = Uri.parse('$_baseUrl$caminho');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    late http.Response resposta;

    switch (metodo) {
      case 'GET':
        if (corpo == null) {
          resposta = await _client.get(uri, headers: headers);
        } else {
          final requisicao = http.Request('GET', uri)
            ..headers.addAll(headers)
            ..body = jsonEncode(corpo);
          final streamed = await _client.send(requisicao);
          resposta = await http.Response.fromStream(streamed);
        }
        break;
      case 'POST':
        resposta = await _client.post(
          uri,
          headers: headers,
          body: corpo == null ? null : jsonEncode(corpo),
        );
        break;
      case 'PUT':
        resposta = await _client.put(
          uri,
          headers: headers,
          body: corpo == null ? null : jsonEncode(corpo),
        );
        break;
      case 'PATCH':
        resposta = await _client.patch(
          uri,
          headers: headers,
          body: corpo == null ? null : jsonEncode(corpo),
        );
        break;
      case 'DELETE':
        resposta = await _client.delete(
          uri,
          headers: headers,
          body: corpo == null ? null : jsonEncode(corpo),
        );
        break;
      default:
        throw FalhaApi('Método HTTP não suportado: $metodo');
    }

    return _interpretarResposta(resposta);
  }

  Map<String, dynamic> _interpretarResposta(http.Response resposta) {
    Map<String, dynamic> dados = {};

    if (resposta.body.isNotEmpty) {
      final decodificado = jsonDecode(resposta.body);
      if (decodificado is Map<String, dynamic>) {
        dados = decodificado;
      } else if (decodificado is List) {
        dados = {'dados': decodificado};
      }
    }

    final sucesso = resposta.statusCode >= 200 && resposta.statusCode < 300;
    if (!sucesso) {
      final mensagem = dados['erro']?.toString() ??
          dados['message']?.toString() ??
          'Erro na requisição (${resposta.statusCode})';
      throw FalhaApi(mensagem, statusCode: resposta.statusCode);
    }

    return dados;
  }

  void encerrar() => _client.close();
}

/// Instância compartilhada utilizada pelos repositórios.
final apiClient = ApiClient();
