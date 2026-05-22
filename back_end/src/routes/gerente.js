import express from 'express';
import * as controller from '../controllers/gerente.js';

const router = express.Router();

// login
router.post('/login', controller.login);

// motoristas
router.get('/motoristas', controller.listarMotoristas);
router.post('/motoristas', controller.criarMotorista);
router.delete('/motoristas/:id', controller.deletarMotorista);


export default router;