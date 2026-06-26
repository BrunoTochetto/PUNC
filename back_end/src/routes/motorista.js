import express from 'express';
import * as controller from '../controllers/motorista.js';
import { autenticacaoNecessaria } from '../middlewares/autenticacao.js';

const router = express.Router();

router.get('/ativos', controller.ativos);

router.get('/identificar', controller.identificarPorMac);

router.patch('/:id/percurso', controller.percursoDispositivo);

router.patch('/:id/status', autenticacaoNecessaria, controller.status);

router.post('/:id/localizacao', controller.localizacao);

router.patch('/acharTodosEmRaio', controller.acharTodosEmRaio);

export default router;