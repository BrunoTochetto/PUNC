import { querry } from '../querry.js';

export function validateCep(cep) {
  return typeof cep === 'string' && cep.trim().length > 0;
}

export function buildDriverSummary(driver) {
  return {
    driverId: driver.driverId,
    cep: driver.cep,
    online: driver.online,
    location: driver.location || null,
    updatedAt: driver.updatedAt,
    trajectoryId: driver.trajectoryId || null,
  };
}

async function createTrajectoryForDriver(driverId, tipoLixo) {
  const sql = `INSERT INTO trajetorias (id_motorista, tipo_lixo) VALUES ($1, $2) RETURNING id`;
  const values = [driverId, tipoLixo || null];
  const resultado = await querry(sql, values);
  return resultado.rows[0]?.id ?? null;
}

async function insertTrajectoryLocation(trajectoryId, location) {
  const sql = `
    INSERT INTO localizacao_trajetorias (id_trajetoria, geom_3857)
    VALUES ($1, ST_Transform(ST_SetSRID(ST_MakePoint($2, $3), 4326), 3857))
  `;
  const values = [trajectoryId, location.longitude, location.latitude];
  await querry(sql, values);
}

async function finishTrajectory(trajectoryId) {
  const sql = `UPDATE trajetorias SET tempo_fim = NOW() WHERE id = $1`;
  await querry(sql, [trajectoryId]);
}

export async function registerDriver(ws, payload, drivers, sendJson, logInfo) {
  const { id, cep, tipoLixo } = payload;
  if (!validateCep(cep)) {
    sendJson(ws, { event: 'error', message: 'CEP do motorista é obrigatório.' });
    return null;
  }

  const driverId = Number(id || ws.metadata.id);
  if (!Number.isInteger(driverId)) {
    sendJson(ws, { event: 'error', message: 'id do motorista deve ser um número inteiro.' });
    return null;
  }

  const trajectoryId = await createTrajectoryForDriver(driverId, tipoLixo);
  if (!trajectoryId) {
    sendJson(ws, { event: 'error', message: 'Não foi possível iniciar trajetória do motorista.' });
    return null;
  }

  ws.metadata.role = 'driver';
  ws.metadata.driverId = driverId;
  ws.metadata.cep = cep;
  ws.metadata.trajectoryId = trajectoryId;

  const driverState = {
    driverId,
    cep,
    online: true,
    location: null,
    updatedAt: new Date().toISOString(),
    trajectoryId,
  };

  drivers.set(String(driverId), driverState);

  const driverInfo = buildDriverSummary(driverState);

  sendJson(ws, {
    event: 'driverRegistered',
    driver: driverInfo,
    message: 'Motorista registrado com sucesso.',
  });
  logInfo(`Motorista registrado: ${driverId}, CEP ${cep}, trajetória ${trajectoryId}`);

  return driverInfo;
}

export async function updateDriverLocation(ws, payload, drivers, sendJson, broadcastToUsersByCep) {
  const { location } = payload;
  if (ws.metadata.role !== 'driver') {
    sendJson(ws, { event: 'error', message: 'Apenas motoristas podem enviar localização.' });
    return;
  }

  if (!location || typeof location.latitude !== 'number' || typeof location.longitude !== 'number') {
    sendJson(ws, { event: 'error', message: 'Location inválida. Use latitude e longitude numéricos.' });
    return;
  }

  const driverId = ws.metadata.driverId;
  const trajectoryId = ws.metadata.trajectoryId;
  if (!driverId || !trajectoryId) {
    sendJson(ws, { event: 'error', message: 'Motorista não registrado ou trajetória não iniciada.' });
    return;
  }

  const driver = drivers.get(String(driverId));
  if (!driver) {
    sendJson(ws, { event: 'error', message: 'Motorista não encontrado.' });
    return;
  }

  driver.location = { ...location };
  driver.updatedAt = new Date().toISOString();
  drivers.set(String(driverId), driver);

  await insertTrajectoryLocation(trajectoryId, location);

  const driverInfo = buildDriverSummary(driver);
  sendJson(ws, { event: 'driverLocationUpdated', driver: driverInfo });
  broadcastToUsersByCep(driver.cep, {
    event: 'driverLocation',
    driver: driverInfo,
  });
}

export async function endDriverTrajectory(metadata, drivers, broadcastToUsersByCep, logInfo) {
  if (!metadata.driverId || !metadata.trajectoryId || !metadata.cep) {
    return;
  }

  await finishTrajectory(metadata.trajectoryId);
  const driverId = metadata.driverId;
  const cep = metadata.cep;

  metadata.trajectoryId = null;
  drivers.delete(String(driverId));
  broadcastToUsersByCep(cep, {
    event: 'driverOffline',
    driverId,
  });
  logInfo(`Trajetória finalizada e motorista offline: ${driverId}, CEP ${cep}`);
}

export async function removeDriver(metadata, drivers, broadcastToUsersByCep, logInfo) {
  if (metadata.driverId && metadata.trajectoryId) {
    await finishTrajectory(metadata.trajectoryId);
  }

  if (!metadata.driverId || !metadata.cep) {
    return;
  }

  drivers.delete(String(metadata.driverId));
  broadcastToUsersByCep(metadata.cep, {
    event: 'driverOffline',
    driverId: metadata.driverId,
  });
  logInfo(`Motorista desconectado: ${metadata.driverId}, CEP ${metadata.cep}`);
}
