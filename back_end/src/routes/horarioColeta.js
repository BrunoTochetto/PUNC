import express from 'express';
import * as controller from '../controllers/horariosColeta.js';
import { autenticacaoNecessaria } from '../middlewares/autenticacao.js';

const router = express.Router();

router.get('/', controller.listar);
router.post('/', autenticacaoNecessaria, controller.criar);
router.put('/:id', autenticacaoNecessaria, controller.editar);

export default router;