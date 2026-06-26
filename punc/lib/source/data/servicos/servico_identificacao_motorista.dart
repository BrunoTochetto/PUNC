import '../modelos/gerente.dart';
import '../repositorios/repositorio_motorista.dart';
import 'servico_preferencias_usuario.dart';

/// Resultado da verificação de cadastro do dispositivo como motorista.
class ResultadoIdentificacaoMotorista {
  const ResultadoIdentificacaoMotorista({
    required this.ehMotorista,
    this.motorista,
    required this.macDispositivo,
  });

  final bool ehMotorista;
  final MotoristaGerente? motorista;
  final String macDispositivo;
}

/// Verifica se o dispositivo atual está cadastrado como motorista por um gerente.
class ServicoIdentificacaoMotorista {
  ServicoIdentificacaoMotorista({
    ServicoPreferenciasUsuario? servicoPreferencias,
    RepositorioMotorista? repositorioMotorista,
  })  : _servicoPreferencias =
            servicoPreferencias ?? ServicoPreferenciasUsuario(),
        _repositorioMotorista =
            repositorioMotorista ?? RepositorioMotorista();

  final ServicoPreferenciasUsuario _servicoPreferencias;
  final RepositorioMotorista _repositorioMotorista;

  Future<ResultadoIdentificacaoMotorista> verificar() async {
    final identificacao =
        await _servicoPreferencias.obterIdentificacaoDispositivo();
    final mac = identificacao.mac;

    try {
      final motorista = await _repositorioMotorista.identificarPorMac(mac: mac);

      return ResultadoIdentificacaoMotorista(
        ehMotorista: motorista != null,
        motorista: motorista,
        macDispositivo: mac,
      );
    } catch (_) {
      return ResultadoIdentificacaoMotorista(
        ehMotorista: false,
        motorista: null,
        macDispositivo: mac,
      );
    }
  }
}
