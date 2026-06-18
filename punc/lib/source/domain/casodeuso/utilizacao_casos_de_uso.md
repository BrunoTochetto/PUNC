# Utilização dos casos de uso — PUNC

Este documento descreve como importar e executar cada caso de uso do front-end Flutter,
com base nos endpoints da branch `back-end`.

## Configuração inicial

A URL da API fica em `lib/nucleo/segredos/api_config.dart`. Por padrão:

- REST: `http://localhost:1000`
- WebSocket: `ws://localhost:8080`

Para apontar para outro ambiente:

```bash
flutter run --dart-define=PUNC_API_URL=https://sua-api.railway.app --dart-define=PUNC_WS_URL=wss://sua-api.railway.app/ws
```

## Como importar

Importe apenas o perfil necessário:

```dart
// Usuário padrão (cidadão)
import 'package:punc/source/domain/casodeuso/casos_de_uso_usuario.dart';

// Dispositivo do motorista
import 'package:punc/source/domain/casodeuso/casos_de_uso_motorista.dart';

// Gerente
import 'package:punc/source/domain/casodeuso/casos_de_uso_gerente.dart';

// Todos os perfis de uma vez (opcional)
import 'package:punc/source/domain/casodeuso/casos_de_uso.dart';
```

## Tratamento de erros

Todos os casos de uso propagam exceções do back-end como `FalhaApi`:

```dart
import 'package:punc/nucleo/erros/falha_api.dart';

try {
  final resultado = await CadastrarUsuario().executar(
    nomeDispositivo: 'Galaxy S21',
    mac: 'AA:BB:CC:DD:EE:FF',
    latitude: -27.2345,
    longitude: -52.0234,
  );
} on FalhaApi catch (e) {
  print('Erro ${e.statusCode}: ${e.mensagem}');
} on ArgumentError catch (e) {
  print('Validação: ${e.message}');
}
```

---

## Usuário padrão

Import: `casos_de_uso_usuario.dart`

### CadastrarUsuario

Cadastra o cidadão com localização inicial e retorna dados da célula (para inscrição no FCM).

**Endpoint:** `POST /api/usuario/cadastro`

```dart
final cadastro = CadastrarUsuario();

final resultado = await cadastro.executar(
  nomeDispositivo: 'Meu Celular',
  mac: 'AA:BB:CC:DD:EE:FF',
  latitude: -27.2345,
  longitude: -52.0234,
);

print(resultado.mensagem);
print('ID usuário: ${resultado.usuario.id}');
print('Célula FCM: ${resultado.usuario.celula.x}, ${resultado.usuario.celula.y}');
```

### ConsultarCronogramaColeta

Lista horários de coleta ativos da região pelo CEP.

**Endpoint:** `GET /api/horariosColeta/:cep`

```dart
final cronograma = ConsultarCronogramaColeta();

final horarios = await cronograma.executar(cep: '89890000');

for (final horario in horarios) {
  print('${horario.diaSemana} — ${horario.horarioEstimado} — ${horario.tipoLixo}');
}
```

### AcompanharCaminhaoNoMapa

Retorna trajetos em andamento com a última localização de cada caminhão.

**Endpoint:** `GET /api/mapa/emPercurso`

```dart
final mapa = AcompanharCaminhaoNoMapa();

// Todos os caminhões em percurso
final trajetos = await mapa.executar();

// Filtrar por gerente (opcional)
final trajetosFiltrados = await mapa.executar(idGerente: 1);

for (final caminhao in trajetos) {
  print('Motorista ${caminhao.idMotorista}: ${caminhao.latitude}, ${caminhao.longitude}');
}
```

### BuscarMotoristasEmRaio

Busca caminhões ativos dentro de um raio (padrão: 1000 m) da residência do usuário.

**Endpoint:** `PATCH /api/motorista/acharTodosEmRaio`

```dart
final busca = BuscarMotoristasEmRaio();

final proximos = await busca.executar(
  latitude: -27.2345,
  longitude: -52.0234,
  raioMetros: 1000,
);

print('${proximos.length} caminhão(ões) próximo(s)');
```

---

## Motorista (dispositivo do caminhão)

Import: `casos_de_uso_motorista.dart`

> Rotas autenticadas exigem token JWT do gerente no `apiClient`.
> Faça login com `LoginGerente` antes de alterar status.

### AtualizarStatusOperacional

Inicia ou encerra o percurso do motorista.

**Endpoint:** `PATCH /api/motorista/:id/status`

```dart
final status = AtualizarStatusOperacional();

// Iniciar rota
final inicio = await status.executar(
  idMotorista: 3,
  status: AtualizarStatusOperacional.emPercurso,
);
print(inicio.mensagem);
print('Trajetória ID: ${inicio.trajetoria.id}');

// Encerrar rota
final fim = await status.executar(
  idMotorista: 3,
  status: AtualizarStatusOperacional.inativo,
);
print(fim.mensagem);
```

### EnviarLocalizacaoMotorista

Envia a posição atual enquanto o motorista está em percurso (intervalo sugerido: ~30 s).

**Endpoint:** `POST /api/motorista/:id/localizacao`

```dart
final localizacao = EnviarLocalizacaoMotorista();

final ponto = await localizacao.executar(
  idMotorista: 3,
  mac: '11:22:33:44:55:66',
  latitude: -27.2350,
  longitude: -52.0240,
);

print('Localização registrada: ${ponto.latitude}, ${ponto.longitude}');
```

### ListarMotoristasAtivos

Lista motoristas do gerente com status "Em percurso" ou "Inativo".

**Endpoint:** `GET /api/motorista/ativos`

```dart
final listagem = ListarMotoristasAtivos();

final motoristas = await listagem.executar(idGerente: 1);

for (final m in motoristas) {
  print('${m.nomeDispositivo} — ${m.status} — ${m.tipoLixo ?? "sem tipo"}');
}
```

---

## Gerente

Import: `casos_de_uso_gerente.dart`

### LoginGerente

Autentica o gerente e armazena o token JWT automaticamente no `apiClient`.

**Endpoint:** `POST /api/gerente/login`

```dart
final login = LoginGerente();

final sessao = await login.executar(
  email: 'gerente@prefeitura.com',
  senha: '123456',
);

print('Bem-vindo, ${sessao.nome} (ID ${sessao.id})');
// sessao.token já está configurado para as próximas requisições autenticadas
```

### ListarMotoristasGerente

Lista todos os motoristas cadastrados pelo gerente.

**Endpoint:** `GET /api/gerente/motoristas`

```dart
final listar = ListarMotoristasGerente();

final motoristas = await listar.executar(idGerente: sessao.id);

for (final m in motoristas) {
  print('ID ${m.idMotorista}: ${m.nomeDispositivo} (${m.mac})');
}
```

### CadastrarMotorista

Cadastra um novo dispositivo de caminhão vinculado ao gerente.

**Endpoint:** `POST /api/gerente/motoristas`

```dart
final cadastrar = CadastrarMotorista();

final novo = await cadastrar.executar(
  idGerente: sessao.id,
  nomeDispositivo: 'Tablet Caminhão 01',
  mac: '11:22:33:44:55:66',
);

print('Motorista criado: ID ${novo.idMotorista}');
```

### RemoverMotorista

Remove um motorista cadastrado.

**Endpoint:** `DELETE /api/gerente/motoristas/:id`

```dart
final remover = RemoverMotorista();

await remover.executar(
  idGerente: sessao.id,
  idMotorista: 5,
);

print('Motorista removido.');
```

### ListarAreasAtuacao

Lista áreas de atuação (grupos por CEP) do gerente.

**Endpoint:** `GET /api/gerente/areaAtuacao`

```dart
final areas = ListarAreasAtuacao();

// Todas as áreas
final todas = await areas.executar(idGerente: sessao.id);

// Filtrar por prefixo de CEP (opcional)
final filtradas = await areas.executar(
  idGerente: sessao.id,
  cep: '89890',
);

for (final area in todas) {
  print('Área ${area.id}: CEP ${area.cep}');
}
```

### CadastrarAreaAtuacao

Cadastra uma nova área de atuação por CEP.

**Endpoint:** `POST /api/gerente/areaAtuacao`

```dart
final criarArea = CadastrarAreaAtuacao();

final area = await criarArea.executar(
  idGerente: sessao.id,
  cep: '89890000',
);

print('Área criada: ID ${area.id} — CEP ${area.cep}');
```

### RemoverAreaAtuacao

Remove uma área de atuação.

**Endpoint:** `DELETE /api/gerente/areaAtuacao/:id`

```dart
final removerArea = RemoverAreaAtuacao();

await removerArea.executar(
  idGerente: sessao.id,
  idAreaAtuacao: 2,
);

print('Área removida.');
```

### CadastrarHorarioColeta

Cadastra um horário de coleta vinculado a uma área de atuação.

**Endpoint:** `POST /api/horariosColeta/`

```dart
final criarHorario = CadastrarHorarioColeta();

final horario = await criarHorario.executar(
  idGerente: sessao.id,
  idAreaAtuacao: 1,
  horarioEstimado: '08:30',
  diaSemana: 'Segunda-feira',
  tipoLixo: 'Reciclável',
  comentarios: 'Coleta na região central',
);

print('Horário criado: ID ${horario.idHorario}');
```

### EditarHorarioColeta

Atualiza campos de um horário existente.

**Endpoint:** `PUT /api/horariosColeta/`

```dart
final editar = EditarHorarioColeta();

final atualizado = await editar.executar(
  idGerente: sessao.id,
  idHorario: 10,
  horarioEstimado: '09:00',
  tipoLixo: 'Orgânico',
);

print('Horário atualizado: ${atualizado.horarioEstimado}');
```

### EditarHorarioColeta.desativar

Desativa um horário (equivalente a "remover" no diagrama de casos de uso).

```dart
final editar = EditarHorarioColeta();

await editar.desativar(
  idGerente: sessao.id,
  idHorario: 10,
);

print('Horário desativado.');
```

### ListarHorariosPorGerente

Lista todos os horários do gerente, incluindo os desativados.

**Endpoint:** `GET /api/horariosColeta/gerente/`

```dart
final listarHorarios = ListarHorariosPorGerente();

final horarios = await listarHorarios.executar(idGerente: sessao.id);

for (final h in horarios) {
  final status = h.ativo == true ? 'ativo' : 'inativo';
  print('[${status}] ${h.diaSemana} ${h.horarioEstimado} — ${h.tipoLixo}');
}
```

---

## Fluxo completo de exemplo

### Cidadão abre o app pela primeira vez

```dart
import 'package:punc/source/domain/casodeuso/casos_de_uso_usuario.dart';

Future<void> configurarUsuario() async {
  final cadastro = CadastrarUsuario();
  final mapa = AcompanharCaminhaoNoMapa();
  final cronograma = ConsultarCronogramaColeta();

  await cadastro.executar(
    nomeDispositivo: 'Meu Celular',
    mac: 'AA:BB:CC:DD:EE:FF',
    latitude: -27.2345,
    longitude: -52.0234,
  );

  final caminhoes = await mapa.executar();
  final horarios = await cronograma.executar(cep: '89890000');

  print('${caminhoes.length} caminhão(ões) em rota');
  print('${horarios.length} horário(s) de coleta');
}
```

### Gerente gerencia motoristas e cronograma

```dart
import 'package:punc/source/domain/casodeuso/casos_de_uso_gerente.dart';

Future<void> painelGerente() async {
  final login = LoginGerente();
  final sessao = await login.executar(
    email: 'gerente@prefeitura.com',
    senha: '123456',
  );

  final idGerente = sessao.id;

  await CadastrarMotorista().executar(
    idGerente: idGerente,
    nomeDispositivo: 'Caminhão Orgânico',
    mac: '11:22:33:44:55:66',
  );

  final motoristas = await ListarMotoristasGerente().executar(
    idGerente: idGerente,
  );

  final areas = await ListarAreasAtuacao().executar(idGerente: idGerente);

  if (areas.isNotEmpty) {
    await CadastrarHorarioColeta().executar(
      idGerente: idGerente,
      idAreaAtuacao: areas.first.id,
      horarioEstimado: '07:00',
      diaSemana: 'Terça-feira',
      tipoLixo: 'Orgânico',
    );
  }

  print('${motoristas.length} motorista(s) cadastrado(s)');
}
```

### Motorista inicia rota e envia localização

```dart
import 'package:punc/source/domain/casodeuso/casos_de_uso_gerente.dart';
import 'package:punc/source/domain/casodeuso/casos_de_uso_motorista.dart';

Future<void> operacaoMotorista() async {
  // Token necessário para PATCH /status
  await LoginGerente().executar(
    email: 'gerente@prefeitura.com',
    senha: '123456',
  );

  const idMotorista = 3;
  const mac = '11:22:33:44:55:66';

  await AtualizarStatusOperacional().executar(
    idMotorista: idMotorista,
    status: AtualizarStatusOperacional.emPercurso,
  );

  await EnviarLocalizacaoMotorista().executar(
    idMotorista: idMotorista,
    mac: mac,
    latitude: -27.2350,
    longitude: -52.0240,
  );

  await AtualizarStatusOperacional().executar(
    idMotorista: idMotorista,
    status: AtualizarStatusOperacional.inativo,
  );
}
```
