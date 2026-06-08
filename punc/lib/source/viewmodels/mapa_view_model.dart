import '../data/modelos/motorista.dart';
import '../domain/casodeuso/usuario/acompanhar_caminhao_no_mapa.dart';

class MapaViewModel {
  MapaViewModel({AcompanharCaminhaoNoMapa? acompanharCaminhao})
      : _acompanharCaminhao =
            acompanharCaminhao ?? AcompanharCaminhaoNoMapa();

  final AcompanharCaminhaoNoMapa _acompanharCaminhao;

  Future<List<LocalizacaoMotorista>> carregarTrajetos({int? idGerente}) {
    return _acompanharCaminhao.executar(idGerente: idGerente);
  }
}
