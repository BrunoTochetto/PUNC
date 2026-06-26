class FalhaApi implements Exception {
  FalhaApi(this.mensagem, {this.statusCode});

  final String mensagem;
  final int? statusCode;

  @override
  String toString() => 'FalhaApi($statusCode): $mensagem';
}
