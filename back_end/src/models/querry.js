import pg from 'pg';
import { logErro, logAviso, logInfo } from './logErrors.js';

const { Pool } = pg;

const pool = new Pool({
  host: process.env.PGHOST,
  port: process.env.PGPORT || 5432,
  database: process.env.PGDATABASE,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
});

async function querry(query, args) {
  try {
    const resultado = await pool.query(query, args);
    return resultado;
  } catch (erro) {
    await logErro('Erro ao executar query no banco de dados', erro);
    throw erro;
  }
}

export {querry};