import express from 'express';
import * as controller from '../controllers/mapa.js';

const router = express.Router();

router.get('/emPercurso', controller.emPercurso);


export default router;