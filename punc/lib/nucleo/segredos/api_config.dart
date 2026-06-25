/// Configuração de conexão com o back-end PUNC.
/// Ajuste [baseUrl] conforme o ambiente (local, Railway, etc.).
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    return String.fromEnvironment('PUNC_API_URL',
    defaultValue: 'http://192.168.0.34:1025');
  }

  static String get wsUrl {
    const url = String.fromEnvironment('PUNC_WS_URL');
    if (url.isNotEmpty) return url;
    return 'ws://localhost:8080';
  }
}
