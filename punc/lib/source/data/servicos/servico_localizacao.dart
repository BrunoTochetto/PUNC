import '../modelos/localizacao_usuario.dart';

class ServicoLocalizacao {
  Future<LocalizacaoUsuario> obterLocalizacaoAtual() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const LocalizacaoUsuario(
      latitude: -27.096,
      longitude: -52.619,
      descricao: 'Loteamento Jardim America',
      cep: '89890000',
    );
  }
}
