import express from 'express';
import * as controller from '../controllers/motorista.js';

const router = express.Router();

// ativos
router.get('/motoristas/ativos', controller.ativos);

// atualizar status
router.patch('/motoristas/:id/status', controller.status);

// mapa
router.get('/mapa/emPercurso', controller.emPercurso);

export default router;