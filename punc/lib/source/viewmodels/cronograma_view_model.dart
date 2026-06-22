import '../data/modelos/horario_coleta.dart';
import '../domain/casodeuso/usuario/consultar_cronograma_coleta.dart';

class CronogramaViewModel {
  CronogramaViewModel({ConsultarCronogramaColeta? consultarCronograma})
      : _consultarCronograma =
            consultarCronograma ?? ConsultarCronogramaColeta();

  final ConsultarCronogramaColeta _consultarCronograma;

  Future<List<HorarioColeta>> carregar({String cep = ''}) async {
    try {
      return await _consultarCronograma.executar(cep: cep);
    } catch (_) {
      // return _cronogramaDesenvolvimento;
      return [];
    }
  }

  static final List<HorarioColeta> _cronogramaDesenvolvimento = [
    HorarioColeta(
      diaSemana: 'Segunda-feira',
      horarioEstimado: '12:30',
      tipoLixo: 'Reciclavel',
    ),
    HorarioColeta(
      diaSemana: 'Terca-feira',
      horarioEstimado: '08:45',
      tipoLixo: 'Orgânico',
    ),
    HorarioColeta(
      diaSemana: 'Segunda-feira',
      horarioEstimado: '12:30',
      tipoLixo: 'Reciclavel',
    ),
    HorarioColeta(
      diaSemana: 'Segunda-feira',
      horarioEstimado: '12:30',
      tipoLixo: 'Reciclavel',
    ),
  ];
}
