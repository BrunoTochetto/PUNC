require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const PORT = 3001

const pool = new Pool({
  host: process.env.PGHOST,
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
});


const app = express();
app.use(cors());
app.use(express.json());


async function inserirObjeto(name, latitude, longitude) {
  const sql = `
    INSERT INTO objects (name, geom)
    VALUES (
      $1,
      ST_SetSRID(ST_MakePoint($2, $3), 4326)
    )
    RETURNING id, name;
  `;

  const values = [name, longitude, latitude];
  const { rows } = await pool.query(sql, values);
  return rows[0];
}



async function acharTodosEmRaio(latitude, longitude, raioM) {
  const sql = `
    SELECT * FROM achar_todos_em_raio($1, $2, $3);
  `;
  
  const values = [latitude, longitude, raioM];
  const { rows } = await pool.query(sql, values);

  return rows;
  // return montarHierarquia(rows, latitude, longitude, raioM);
}


// Refatorar -> Capaz de nem precisar
function montarHierarquia(rows, latitude, longitude, raioM) {
  const regionsMap = new Map();

  for (const row of rows) {
    const regionId = `${row.region_x}:${row.region_y}`;
    const cellId = `${row.cell_x}:${row.cell_y}`;

    if (!regionsMap.has(regionId)) {
      regionsMap.set(regionId, {
        regionId,
        regionX: Number(row.region_x),
        regionY: Number(row.region_y),
        totalObjects: 0,
        totalCells: 0,
        cellsMap: new Map(),
      });
    }

    const region = regionsMap.get(regionId);

    if (!region.cellsMap.has(cellId)) {
      region.cellsMap.set(cellId, {
        cellId,
        cellX: Number(row.cell_x),
        cellY: Number(row.cell_y),
        totalObjects: 0,
        objects: [],
      });
      region.totalCells += 1;
    }

    const cell = region.cellsMap.get(cellId);

    const object = {
      id: Number(row.object_id),
      name: row.object_name,
      latitude: Number(row.latitude),
      longitude: Number(row.longitude),
      distanceM: Number(row.distance_m),
    };

    cell.objects.push(object);
    cell.totalObjects += 1;
    region.totalObjects += 1;
  }

  const regions = Array.from(regionsMap.values()).map(region => {
    const cells = Array.from(region.cellsMap.values())
      .sort((a, b) => {
        if (a.cellY !== b.cellY) return a.cellY - b.cellY;
        return a.cellX - b.cellX;
      });

    return {
      regionId: region.regionId,
      regionX: region.regionX,
      regionY: region.regionY,
      totalObjects: region.totalObjects,
      totalCells: region.totalCells,
      cells,
    };
  });

  regions.sort((a, b) => {
    if (a.regionY !== b.regionY) return a.regionY - b.regionY;
    return a.regionX - b.regionX;
  });

  const totalObjects = regions.reduce((sum, r) => sum + r.totalObjects, 0);
  const totalCells = regions.reduce((sum, r) => sum + r.totalCells, 0);

  return {
    search: {
      latitude,
      longitude,
      radiusM: raioM,
      regionSizeM: 1000,
      cellSizeM: 100,
    },
    summary: {
      totalRegions: regions.length,
      totalCells,
      totalObjects,
    },
    regions,
  };
}




app.post('/postesCriar', async (req, res) => {
  try {
    const { latitude, longitude, status } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ erro: 1, mensagem: 'latitude, longitude são obrigatórios.' });
    }

    const novoPoste = inserirObjeto('Imigrantes', latitude, longitude);

    res.status(201).json(novoPoste);
  } catch (error) {
    console.error('Erro ao criar poste:', error);
    res.status(500).json({ erro: 1, mensagem: 'Erro interno ao criar poste.' });
  }
});

app.post('/raio', async (req, res) => {
  try {

    const { latitude, longitude, status } = req.body;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ erro: 1, mensagem: 'latitude, longitude são obrigatórios.' });
    }
    

    const novoPoste = await acharTodosEmRaio(latitude, longitude, 1000);
    

    res.status(201).json(novoPoste);
  } catch (error) {
    console.error('Erro ao criar poste:', error);
    res.status(500).json({ erro: 1, mensagem: 'Erro interno ao criar poste.' });
  }
});






// ---------------- START ----------------
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
});


