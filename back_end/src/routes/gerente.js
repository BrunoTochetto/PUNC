import express from 'express';
import * as controller from '../controllers/gerente.js';
import { autenticar } from '../middlewares/autenticacao.js';

const router = express.Router();

// login
router.post('/login', controller.login);

// motoristas (rotas protegidas com autenticação)
router.get('/motoristas', autenticar, controller.listarMotoristas);
router.post('/motoristas', autenticar, controller.criarMotorista);
router.delete('/motoristas/:id', autenticar, controller.deletarMotorista);


export default router;