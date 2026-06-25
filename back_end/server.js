import express, { json } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';

dotenv.config({ path: fileURLToPath(new URL('./.env', import.meta.url)) });
import { logInfo } from './src/services/logErrors.js';
import { initFirebase } from './src/services/firebase.js';

import usuarioRoutes from './src/routes/usuario.js';
import gerenteRoutes from './src/routes/gerente.js';
import motoristaRoutes from './src/routes/motorista.js';
import mapaRoutes from './src/routes/mapa.js';
import horarioColetaRoutes from './src/routes/horarioColeta.js';
import { notificacoes } from './src/services/notificacoes.js';
// import './src/services/websocket.js';

const app = express();

initFirebase();

app.use(helmet());
app.use(cors());
app.use(json());

// USAR ROTAS
app.use('/api/usuario', usuarioRoutes);
app.use('/api/gerente', gerenteRoutes);
app.use('/api/motorista', motoristaRoutes);
app.use('/api/mapa', mapaRoutes);
app.use('/api/horariosColeta', horarioColetaRoutes);

app.get('/status', (req, res) => {
    res.json({ message: 'API funcionando.' });
});


const PORT = process.env.PORT || 1025; // Desculpa Heitor, não sabia que não podia 1000
app.listen(PORT, () => {
    // console.log(`Server rodando na porta: ${PORT}`);
    logInfo(`Server rodando na porta: ${PORT}`);
});
