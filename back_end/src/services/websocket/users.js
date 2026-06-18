import { WebSocket } from 'ws';
import { querry } from '../querry.js';

export function buildUserSummary(user) {
  return {
    userId: user.userId,
    cep: user.cep,
  };
}

export function getDriversForCep(cep, drivers) {
  return Array.from(drivers.values())
    .filter((driver) => driver.cep === cep && driver.online)
    .map((driver) => ({
      driverId: driver.driverId,
      cep: driver.cep,
      location: driver.location || null,
      updatedAt: driver.updatedAt,
      online: driver.online,
      trajectoryId: driver.trajectoryId || null,
    }));
}

async function getTrajectoryHistory(trajectoryId) {
  const sql = `
    SELECT
      ST_Y(ST_Transform(geom_3857, 4326)) AS latitude,
      ST_X(ST_Transform(geom_3857, 4326)) AS longitude,
      data_criacao AS timestamp
    FROM localizacao_trajetorias
    WHERE id_trajetoria = $1
    ORDER BY data_criacao ASC
  `;
  const result = await querry(sql, [trajectoryId]);
  return result.rows;
}

export async function registerUser(ws, payload, sendJson, drivers, logInfo) {
  const { id, cep } = payload;
  if (!cep || typeof cep !== 'string') {
    sendJson(ws, { event: 'error', message: 'CEP do usuário é obrigatório.' });
    return null;
  }

  ws.metadata.role = 'user';
  ws.metadata.userId = String(id || ws.metadata.id);
  ws.metadata.cep = cep;

  const userSummary = buildUserSummary(ws.metadata);

  sendJson(ws, {
    event: 'userRegistered',
    user: userSummary,
    message: 'Usuário registrado com sucesso.',
  });

  const driversInCep = getDriversForCep(cep, drivers);
  sendJson(ws, {
    event: 'activeDrivers',
    drivers: driversInCep,
  });

  for (const driver of driversInCep) {
    if (driver.trajectoryId) {
      const history = await getTrajectoryHistory(driver.trajectoryId);
      sendJson(ws, {
        event: 'driverHistory',
        driverId: driver.driverId,
        trajectoryId: driver.trajectoryId,
        history,
      });
    }
  }

  logInfo(`Usuário registrado: ${ws.metadata.userId}, CEP ${cep}`);
  return userSummary;
}

export function broadcastToUsersByCep(cep, payload, clients) {
  for (const client of clients.values()) {
    if (client.metadata?.role === 'user' && client.metadata.cep === cep && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(payload));
    }
  }
}
