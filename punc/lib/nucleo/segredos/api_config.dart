/// Configuração de conexão com o back-end PUNC.
/// Ajuste [baseUrl] conforme o ambiente (local, Railway, etc.).
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'PUNC_API_URL',
    defaultValue: 'http://localhost:1000',
  );

  static const String wsUrl = String.fromEnvironment(
    'PUNC_WS_URL',
    defaultValue: 'ws://localhost:8080',
  );
}
