import express, { json } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

import usuarioRoutes from './src/routes/usuario.js';
import gerenteRoutes from './src/routes/gerente.js';
import motoristaRoutes from './src/routes/motorista.js';
import mapaRoutes from './src/routes/mapa.js';
import horarioColetaRoutes from './src/routes/horarioColeta.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(json());

// USAR ROTAS
app.use('/api/usuario', usuarioRoutes);
app.use('/api/gerente', gerenteRoutes);
app.use('/api/motoristas', motoristaRoutes);
app.use('/api/mapa', mapaRoutes);
app.use('/api/horariosColeta', horarioColetaRoutes);

app.get('/status', (req, res) => {
    res.json({ message: 'API funcionando.' });
});


const PORT = process.env.PORT || 1000;
console.log(process)
app.listen(PORT, () => {
    console.log(`Server rodando na porta: ${PORT}`);
});