import express from 'express';
import * as controller from '../controllers/horariosColeta.js';
import { autenticacaoNecessaria } from '../middlewares/autenticacao.js';

const router = express.Router();

router.get('/gerente/', autenticacaoNecessaria, controller.listarPorGerente);
router.get('/', controller.listar);
router.post('/', autenticacaoNecessaria, controller.criar);
router.put('/', autenticacaoNecessaria, controller.editar);
router.delete('/', autenticacaoNecessaria, controller.deletar);
router.get('/:cep', controller.listar);

export default router;
