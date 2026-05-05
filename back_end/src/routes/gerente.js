import express from 'express';
import * as controller from '../controllers/gerente.js';

const router = express.Router();

// login
router.post('/gerentes/login', controller.login);

// motoristas
router.get('/gerente/motoristas', controller.listarMotoristas);
router.post('/gerente/motoristas', controller.criarMotorista);
router.delete('/gerente/motoristas/:id', controller.deletarMotorista);

// horários
router.get('/horariosColeta', controller.listarHorarios);
router.post('/horariosColeta', controller.criarHorario);
router.put('/horariosColeta/:id', controller.editarHorario);

export default router;