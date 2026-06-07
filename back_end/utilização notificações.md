# Utilização — Notificações (Firebase / FCM)

Este documento descreve como o back-end do PUNC envia notificações push **apenas por tópicos FCM**.

## Visão geral

| Responsabilidade | Onde |
|------------------|------|
| Criar o tópico da célula | Back-end (`Notificacoes.criarTopicoCelula`) |
| Inscrever o dispositivo no tópico | Front-end (Flutter + Firebase Messaging) |
| Enviar notificações | Back-end (`Notificacoes.enviarTopico`, etc.) |

Cada usuário pertence a uma **célula** da grade (100 m × 100 m). O tópico FCM segue o padrão:

```
celula_{cell_x}_{cell_y}
```

Exemplo: célula `(123, 456)` → tópico `celula_123_456`.

---

## Configuração do Firebase

1. No [Firebase Console](https://console.firebase.google.com), gere uma **Service Account** (Project Settings → Service accounts → Generate new private key).
2. Salve o JSON em `back_end/firebase-service-account.json` (não versionar).
3. Configure o `.env` (copie de `.env.example`):

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

Alternativas suportadas:

- `FIREBASE_SERVICE_ACCOUNT` — JSON inline
- `FIREBASE_PROJECT_ID` + `FIREBASE_CLIENT_EMAIL` + `FIREBASE_PRIVATE_KEY`

O Firebase Admin é inicializado em `server.js` via `initFirebase()`.

---

## Classe `Notificacoes`

Arquivo: `src/services/notificacoes.js`

Importação recomendada (singleton):

```javascript
import { notificacoes } from '../services/notificacoes.js';
```

### Métodos públicos

| Método | Descrição |
|--------|-----------|
| `celulaParaTopico(celulaX, celulaY)` | Gera e valida o nome do tópico |
| `validarTopico(topico)` | Valida formato FCM |
| `criarTopicoCelula(celulaX, celulaY)` | Cria/registra o tópico no FCM (mensagem data-only) |
| `enviarTopico(topico, payload)` | Envia notificação para um tópico |
| `enviarCelula(celulaX, celulaY, payload)` | Envia notificação para a célula |
| `enviarTopicos(topicos, payload)` | Envia em lote para vários tópicos |
| `notificarCelulasEmRaio(lat, lon, raioM, payload)` | Notifica células dentro de um raio (PostGIS) |
| `montarPayloadColeta(tipoLixo, opcoes)` | Monta título, corpo e `dados.tipo_lixo` |
| `normalizarTipoLixo(tipoLixo)` | Valida e normaliza `organico` / `reciclado` |
| `rotuloTipoLixo(tipoLixo)` | Retorna rótulo legível (`orgânico` / `reciclável`) |

### Payload de envio

Campos básicos:

```javascript
{
  titulo: 'Título visível',
  corpo: 'Texto da notificação',
  dados: { evento: 'coleta_proxima' } // opcional, chave/valor string
}
```

### Tipo de lixo (orgânico ou reciclável)

Recomendado usar **os dois**:

1. **Texto visível** — `titulo` e `corpo` (o usuário vê na bandeja de notificações)
2. **`dados`** — para o app tratar programaticamente (abrir tela certa, ícone, etc.)

Use o helper `montarPayloadColeta` ou passe `tipoLixo` no payload:

```javascript
// Opção 1 — helper (recomendado)
await notificacoes.enviarCelula(
  123,
  456,
  notificacoes.montarPayloadColeta('organico')
);

// Opção 2 — tipoLixo no payload (monta texto + dados automaticamente)
await notificacoes.enviarCelula(123, 456, {
  tipoLixo: 'reciclado',
});

// Opção 3 — manual (controle total do texto e dos dados)
await notificacoes.enviarCelula(123, 456, {
  titulo: 'Coleta de lixo orgânico',
  corpo: 'O caminhão de coleta orgânica está a caminho da sua região.',
  dados: {
    evento: 'coleta_proxima',
    tipo_lixo: 'organico',
  },
});
```

Valores aceitos para `tipoLixo` / `tipo_lixo`:

| Valor enviado | Normalizado | Texto exibido |
|---------------|-------------|---------------|
| `organico`, `orgânico`, `organica` | `organico` | orgânico |
| `reciclado`, `reciclavel` | `reciclado` | reciclável |

Exemplo do que chega no dispositivo:

```javascript
// notification (visível)
{
  title: 'Coleta de lixo orgânico',
  body: 'O caminhão de coleta orgânico está a caminho da sua região.'
}

// data (para o app Flutter)
{
  evento: 'coleta_proxima',
  tipo_lixo: 'organico'
}
```

> **Sobre `dados.tipo`:** dá para usar, mas neste projeto reservamos `dados.evento` para o tipo da notificação (`coleta_proxima`) e `dados.tipo_lixo` para orgânico/reciclável, evitando ambiguidade no front-end.

---

## Cadastro de usuário e tópico

No `POST /api/usuario/cadastro`, após inserir o usuário:

1. O back-end obtém `cell_x` e `cell_y` da célula.
2. Chama `notificacoes.criarTopicoCelula(cell_x, cell_y)`.
3. Retorna o nome do tópico na resposta.

Exemplo de resposta:

```json
{
  "mensagem": "Usuário cadastrado com sucesso",
  "usuario": {
    "id": 1,
    "id_celula": 10,
    "id_regiao": 2,
    "celula": {
      "x": 123,
      "y": 456,
      "topico": "celula_123_456"
    }
  }
}
```

### Front-end: inscrição no tópico

Após o cadastro, o app Flutter deve inscrever o dispositivo no tópico retornado:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

final topico = resposta['usuario']['celula']['topico'];
await FirebaseMessaging.instance.subscribeToTopic(topico);
```

> A **criação** do tópico é responsabilidade do back-end. A **inscrição** do dispositivo é responsabilidade do front-end.

---

## Exemplos de uso no back-end

### Notificar uma célula

```javascript
await notificacoes.enviarCelula(123, 456, notificacoes.montarPayloadColeta('organico'));
```

### Notificar células em raio (ex.: localização do motorista)

```javascript
await notificacoes.notificarCelulasEmRaio(-27.234, -52.023, 500, {
  tipoLixo: 'reciclado',
});
```

### Enviar para tópico customizado

```javascript
await notificacoes.enviarTopico('celula_123_456', {
  titulo: 'Aviso',
  corpo: 'Mensagem de teste.',
});
```

---

## Comportamento sem Firebase configurado

Se as credenciais não estiverem definidas:

- O servidor **continua funcionando**.
- `criarTopicoCelula` e `enviarTopico` retornam `{ criado: false, motivo: 'firebase_nao_configurado' }` (ou equivalente).
- Um aviso é registrado nos logs.

---

## Arquivos relacionados

| Arquivo | Função |
|---------|--------|
| `src/services/firebase.js` | Inicialização do Firebase Admin |
| `src/services/notificacoes.js` | Classe `Notificacoes` |
| `src/controllers/usuario.js` | Criação do tópico no cadastro |
| `.env.example` | Variáveis de ambiente |
