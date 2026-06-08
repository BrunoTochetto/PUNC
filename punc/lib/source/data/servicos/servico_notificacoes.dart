import '../modelos/usuario.dart';

class InscricaoNotificacao {
  const InscricaoNotificacao({
    required this.inscrito,
    required this.topico,
  });

  final bool inscrito;
  final String topico;
}

class ServicoNotificacoes {
  Future<void> inicializar() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<InscricaoNotificacao> inscreverUsuario(
    ResultadoCadastroUsuario cadastro,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final x = cadastro.usuario.celula.x;
    final y = cadastro.usuario.celula.y;
    final topico = x == null || y == null ? 'punc-geral' : 'celula-$x-$y';

    return InscricaoNotificacao(inscrito: true, topico: topico);
  }
}
