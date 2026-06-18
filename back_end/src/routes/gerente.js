import express from 'express';
import * as controller from '../controllers/gerente.js';
import { autenticacaoNecessaria } from '../middlewares/autenticacao.js';

const router = express.Router();

// login
router.post('/login', controller.login);

// motoristas (rotas protegidas com autenticação)
router.get('/motoristas', autenticacaoNecessaria, controller.listarMotoristas);
router.post('/motoristas', autenticacaoNecessaria, controller.criarMotorista);
router.delete('/motoristas/:id', autenticacaoNecessaria, controller.deletarMotorista);

// area de atuação
router.get("/areaAtuacao", autenticacaoNecessaria, controller.listarAreasAtuacao);
router.post('/areaAtuacao', autenticacaoNecessaria, controller.criarAreaAtuacao);
router.delete('/areaAtuacao/:id', autenticacaoNecessaria, controller.deletarAreaAtuacao);

export default router;