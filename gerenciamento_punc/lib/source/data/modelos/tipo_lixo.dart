/// Tipos de lixo aceitos para rotas de motorista.
class TipoLixo {
  const TipoLixo._();

  static const organico = 'organico';
  static const reciclado = 'reciclado';

  static const valores = [organico, reciclado];

  static const rotulos = {
    organico: 'Orgânico',
    reciclado: 'Reciclado',
  };

  static const diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static String rotulo(String valor) =>
      rotulos[normalizar(valor)] ?? valor;

  static String? normalizar(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;

    final texto = valor.toLowerCase().trim();
    if (texto.contains('organ') || texto.contains('orgân')) {
      return organico;
    }
    if (texto.contains('recicl')) {
      return reciclado;
    }
    return null;
  }
}
