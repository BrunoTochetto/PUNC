import '../data/modelos/perfil_usuario.dart';

class PerfilViewModel {
  Future<PerfilUsuario?> carregarPerfil() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const PerfilUsuario(
      nome: 'Nicoly Quechini',
      email: 'nicolyquechini6@gmail.com',
      telefone: '(49) 93485934869',
      modoEscuro: false,
      idioma: 'Portugues',
      notificacaoEmail: true,
    );
  }
}
