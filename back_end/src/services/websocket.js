import { WebSocket, WebSocketServer } from 'ws';
import { logInfo, logErro } from './logErrors.js';
import { registerDriver, updateDriverLocation, removeDriver, endDriverTrajectory } from './websocket/drivers.js';
import { registerUser, broadcastToUsersByCep } from './websocket/users.js';

const wsPort = process.env.WS_PORT ? Number(process.env.WS_PORT) : 8080;
const wss = new WebSocketServer({ port: wsPort });

const clients = new Map();
const drivers = new Map();

function parseMessage(message) {
  try {
    return JSON.parse(message.toString());
  } catch (error) {
    return null;
  }
}

function sendJson(ws, payload) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(payload));
  }
}

function createClientMetadata(ws) {
  return {
    id: crypto.randomUUID(),
    role: 'unknown',
    userId: null,
    driverId: null,
    cep: null,
    trajectoryId: null,
    ws,
  };
}

wss.on('listening', () => {
  logInfo(`WebSocket server rodando na porta ${wsPort}`);
});

wss.on('connection', (ws) => {
  const metadata = createClientMetadata(ws);
  clients.set(metadata.id, ws);
  ws.metadata = metadata;

  logInfo(`Novo cliente WebSocket conectado: ${metadata.id}`);
  sendJson(ws, {
    event: 'welcome',
    message: 'Envie action="register" com role="driver" ou "user", campo cep e, para encerrar, action="endTrajectory".',
  });

  ws.on('message', async (rawMessage) => {
    const payload = parseMessage(rawMessage);
    if (!payload || typeof payload !== 'object') {
      sendJson(ws, { event: 'error', message: 'Payload JSON inválido.' });
      return;
    }

    const { action, role } = payload;

    switch (action) {
      case 'register': {
        if (role === 'driver') {
          await registerDriver(ws, payload, drivers, sendJson, logInfo);
          return;
        }

        if (role === 'user') {
          await registerUser(ws, payload, sendJson, drivers, logInfo);
          return;
        }

        sendJson(ws, { event: 'error', message: 'Role deve ser "driver" ou "user".' });
        return;
      }

      case 'locationUpdate': {
        await updateDriverLocation(ws, payload, drivers, sendJson, (cep, data) => broadcastToUsersByCep(cep, data, clients));
        return;
      }

      case 'endTrajectory': {
        if (ws.metadata.role !== 'driver') {
          sendJson(ws, { event: 'error', message: 'Apenas motoristas podem encerrar trajetórias.' });
          return;
        }
        await endDriverTrajectory(ws.metadata, drivers, (cep, data) => broadcastToUsersByCep(cep, data, clients), logInfo);
        sendJson(ws, { event: 'trajectoryEnded', driverId: ws.metadata.driverId });
        return;
      }

      case 'ping': {
        sendJson(ws, { event: 'pong', timestamp: new Date().toISOString() });
        return;
      }

      default: {
        sendJson(ws, { event: 'error', message: 'Ação desconhecida. Use register, locationUpdate ou endTrajectory.' });
      }
    }
  });

  ws.on('close', async () => {
    clients.delete(metadata.id);
    if (metadata.role === 'driver') {
      await removeDriver(metadata, drivers, (cep, data) => broadcastToUsersByCep(cep, data, clients), logInfo);
    }
    logInfo(`Cliente desconectado: ${metadata.id}`);
  });

  ws.on('error', (error) => {
    logErro('Erro no WebSocket', error);
  });
});
