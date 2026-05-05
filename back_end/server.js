import express, { json } from 'express';
import helmet from 'helmet';
import cors from 'cors';

// IMPORTAR ROTAS
import usuarioRoutes from './src/routes/usuario.js';
import gerenteRoutes from './src/routes/gerente.js';
import motoristaRoutes from './src/routes/motorista.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(json());

// USAR ROTAS
app.use('/api', usuarioRoutes);
app.use('/api', gerenteRoutes);
app.use('/api', motoristaRoutes);

app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the API' });
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});