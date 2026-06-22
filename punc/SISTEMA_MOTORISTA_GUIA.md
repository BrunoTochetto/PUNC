# Sistema de Estado do Motorista - Guia de Integração

## Visão Geral

Este sistema implementa o gerenciamento de estado específico para motoristas, controlando a coleta e envio periódico de localização em tempo real para o backend.

## Arquitetura

### Componentes Principais

1. **ServicoLocalizacaoMotorista** (`servico_localizacao_motorista.dart`)
   - Responsável pela lógica de coleta e envio periódico de localização
   - Gerencia timer, permissões e estado de coleta
   - Independente da UI

2. **MotoristaViewModel** (`motorista_view_model.dart`)
   - ViewModel seguindo o padrão MVVM do projeto
   - Estende `ChangeNotifier` para reatividade
   - Gerencia status operacional do motorista
   - Interface entre UI e serviço de localização

3. **MotoristaPaginaExemplo** (`motorista_pagina_exemplo.dart`)
   - Exemplo de implementação em UI
   - Demonstra como consumir o ViewModel com Provider
   - Mostra feedback visual de estado e erros

## Fluxo de Funcionamento

```
┌─────────────────────────────────────────────────────────┐
│                    Autenticação                         │
│            (Motorista identificado/logado)              │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│      MotoristaViewModel.definirMotorista(id)            │
│              (ID do motorista salvo)                    │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────┐
        │  Motorista clica em      │
        │  "Iniciar Percurso"      │
        └──────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────────┐
    │ iniciarPercurso()                │
    │ ├─ Inicia ServicoLocalizacao     │
    │ └─ Atualiza status no backend    │
    └──────────┬───────────────────────┘
               │
               ▼
    ┌──────────────────────────────────┐
    │  Timer começa (cada 30s)         │
    │  ├─ Obtém localização            │
    │  ├─ Envia ao backend             │
    │  └─ Notifica UI de mudança       │
    └──────────┬───────────────────────┘
               │
               ▼
        ┌──────────────────────────┐
        │  Motorista clica em      │
        │  "Finalizar"             │
        └──────────┬───────────────┘
                   │
                   ▼
    ┌──────────────────────────────────┐
    │ finalizarPercurso()              │
    │ ├─ Para timer                    │
    │ ├─ Atualiza status no backend    │
    │ └─ Notifica UI de mudança        │
    └──────────────────────────────────┘
```

## Integração no Projeto

### 1. Provider Setup (main.dart ou inicialização)

```dart
import 'package:provider/provider.dart';
import 'source/viewmodels/motorista_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MotoristaViewModel(),
        ),
        // ... outros providers
      ],
      child: const MinhaApp(),
    ),
  );
}
```

### 2. Usar na Tela do Motorista

```dart
import 'package:provider/provider.dart';
import 'viewmodels/motorista_view_model.dart';

class MinhaTelaMotorista extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MotoristaViewModel>(
      builder: (context, motorista, _) {
        return Column(
          children: [
            Text('Status: ${motorista.estaEmPercurso ? "Em Percurso" : "Inativo"}'),
            
            ElevatedButton(
              onPressed: motorista.estaEmPercurso
                  ? null
                  : () => motorista.iniciarPercurso(),
              child: const Text('Iniciar'),
            ),
            
            if (motorista.mensagemErro != null)
              Text(motorista.mensagemErro!),
          ],
        );
      },
    );
  }
}
```

### 3. Definir Motorista Autenticado

Após o login/autenticação do motorista:

```dart
// Em seu login/autenticação
final idMotorista = usuarioAutenticado.id;
context.read<MotoristaViewModel>().definirMotorista(idMotorista);
```

## Estados e Transições

### Estados do Motorista
- **Inativo**: Não está coletando localização
- **Em Percurso**: Está coletando e enviando localização

### Estados de Coleta (Interno)
- **Inativo**: Serviço não ativo
- **Coletando**: Aguardando próximo intervalo
- **Enviando**: Enviando localização ao backend
- **Erro**: Ocorreu um erro na coleta/envio

## Tratamento de Erros

O sistema trata automaticamente os seguintes cenários:

1. **Sem Permissão de Localização**
   - Solicita permissão automaticamente
   - Notifica erro se negada

2. **Sem Conectividade**
   - Continua tentando enviar
   - Notifica erro na UI
   - Mantém timer ativo para próxima tentativa

3. **MAC do Dispositivo Não Configurado**
   - Notifica erro específico
   - Orienta usuário a configurar dispositivo

4. **Motorista Não Identificado**
   - Previne início de coleta
   - Notifica que motorista deve ser definido

## Integração com Backend

### Endpoint Utilizado

```
POST /api/motorista/:id/localizacao
Body: {
  mac: string,           // MAC do dispositivo (obtido de preferências)
  latitude: number,      // Latitude atual
  longitude: number      // Longitude atual
}
```

### Endpoint de Status

```
PATCH /api/motorista/:id/status
Body: {
  status: "Em percurso" | "Inativo"
}
```

## Ciclo de Vida

### Inicialização
1. MotoristaViewModel é criado via Provider
2. ServicoLocalizacaoMotorista é instanciado
3. Callbacks são configurados

### Durante Percurso
1. Timer ativa a cada 30s
2. ServicoLocalizacao obtém posição GPS
3. RepositorioMotorista envia ao backend
4. UI é notificada de mudanças via notifyListeners()

### Finalização
1. Timer é cancelado
2. Estado volta a Inativo
3. Backend é notificado de finalização

### Dispose
- Recursos são liberados quando ViewModel é descartado
- Timer é cancelado automaticamente

## Exemplo Completo de Integração

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'source/viewmodels/motorista_view_model.dart';

class MinhaTelaMotorista extends StatefulWidget {
  @override
  State<MinhaTelaMotorista> createState() => _MinhaTelaMotoristaState();
}

class _MinhaTelaMotoristaState extends State<MinhaTelaMotorista> {
  @override
  void initState() {
    super.initState();
    // Definir motorista após autenticação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idMotorista = obterIdMotoristaAutenticado();
      context.read<MotoristaViewModel>().definirMotorista(idMotorista);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MotoristaViewModel>(
      builder: (context, motorista, _) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: motorista.estaEmPercurso
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    motorista.estaEmPercurso
                        ? 'Em Percurso'
                        : 'Inativo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão para iniciar
                ElevatedButton.icon(
                  onPressed: motorista.estaEmPercurso
                      ? null
                      : () async {
                          final sucesso =
                              await motorista.iniciarPercurso();
                          if (!sucesso && mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  motorista.mensagemErro ??
                                      'Erro ao iniciar',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Percurso'),
                ),

                const SizedBox(height: 12),

                // Botão para finalizar
                ElevatedButton.icon(
                  onPressed: motorista.estaInativo
                      ? null
                      : () async {
                          final sucesso =
                              await motorista.finalizarPercurso();
                          if (!sucesso && mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  motorista.mensagemErro ??
                                      'Erro ao finalizar',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar Percurso'),
                ),

                // Mostrar loading se estiver enviando
                if (motorista.estaSincronizando) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('Enviando localização...'),
                ],

                // Mostrar erro se houver
                if (motorista.mensagemErro != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      motorista.mensagemErro!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  int obterIdMotoristaAutenticado() {
    // Implementar sua lógica de autenticação
    // return secureStorage.getIdMotorista();
    return 1; // Placeholder
  }
}
```

## Debugging

Para debug, verifique os logs:

```
[PUNC motorista] Coleta de localização iniciada.
[PUNC motorista] Localização enviada: lat=..., lon=...
[PUNC motorista] Coleta de localização parada.
[PUNC motorista] Erro: ...
```

## Performance e Boas Práticas

1. **Limpar Recursos**: Sempre chame `dispose()` no ViewModel
2. **Permissão de Localização**: Solicitar no primeiro uso
3. **Battery**: O timer de 30s é otimizado para não drenar bateria
4. **Conectividade**: O sistema detecta e reporta falhas de rede
5. **Background**: Considere usar `service_locator` se precisar rodar em background

## Próximas Etapas (Futuro)

- [ ] Implementar coleta em background com `background_fetch`
- [ ] Adicionar histórico de localizações enviadas
- [ ] Implementar retry automático com backoff exponencial
- [ ] Adicionar geofencing para parar coleta automaticamente
- [ ] Dashboard de análise de rota

---

**Arquivos Criados:**
- `servico_localizacao_motorista.dart` - Serviço de localização periódica
- `motorista_view_model.dart` - ViewModel do motorista
- `motorista_pagina_exemplo.dart` - Exemplo de integração na UI
- `servico_localizacao_motorista.dart` exportado em `dados_backend.dart`

**Requisitos:**
- Provider package (provider: ^6.0.0 ou superior)
- Geolocator package (geolocator: ^9.0.0 ou superior) - já em pubspec.yaml
