/// Configuração de conexão com o back-end PUNC.
/// Ajuste [baseUrl] conforme o ambiente (local, Railway, etc.).
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'PUNC_API_URL',
    defaultValue: 'http://192.168.0.34:1025',
  );

  static const String wsUrl = String.fromEnvironment(
    'PUNC_WS_URL',
    defaultValue: 'ws://localhost:8080',
  );
}
