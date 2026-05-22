import express from 'express';
import * as controller from '../controllers/horariosColeta.js';

const router = express.Router();

// horários
router.get('/', controller.listar);
router.post('/', controller.criar);
router.put('/:id', controller.editar);

export default router;