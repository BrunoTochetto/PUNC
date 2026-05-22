
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');


const PORT = 3001




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




