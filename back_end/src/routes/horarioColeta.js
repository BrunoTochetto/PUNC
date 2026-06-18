import express from 'express';
import * as controller from '../controllers/horariosColeta.js';
import { autenticacaoNecessaria } from '../middlewares/autenticacao.js';

const router = express.Router();

router.get('/:cep', controller.listar);
router.post('/', autenticacaoNecessaria, controller.criar);
router.put('/', autenticacaoNecessaria, controller.editar);
router.get('/gerente/', autenticacaoNecessaria, controller.listarPorGerente);

export default router;