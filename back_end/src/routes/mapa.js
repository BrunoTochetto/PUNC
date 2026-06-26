import express from 'express';
import * as controller from '../controllers/mapa.js';

const router = express.Router();

router.get('/emPercurso', controller.emPercurso);
router.get('/emPercurso/:id_gerente', controller.emPercurso);


export default router;