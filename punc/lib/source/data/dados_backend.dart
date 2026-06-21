/// Barrel file — exporta a camada de dados (repositórios, modelos e cliente HTTP).
library;

export 'api_client.dart';
export 'modelos/usuario.dart';
export 'modelos/gerente.dart';
export 'modelos/motorista.dart';
export 'modelos/horario_coleta.dart';
export 'modelos/localizacao_usuario.dart';
export 'modelos/perfil_usuario.dart';
export 'repositorios/repositorio_usuario.dart';
export 'repositorios/repositorio_gerente.dart';
export 'repositorios/repositorio_motorista.dart';
export 'repositorios/repositorio_mapa.dart';
export 'repositorios/repositorio_horario_coleta.dart';
export 'servicos/servico_localizacao.dart';
export 'servicos/servico_localizacao_motorista.dart';
export 'servicos/servico_notificacoes.dart';
export 'servicos/servico_preferencias_usuario.dart';
