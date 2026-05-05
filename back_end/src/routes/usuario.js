import express from 'express';
import * as controller from '../controllers/usuario.js';

const router = express.Router();

router.post('/users/cadastro', controller.cadastro);

export default router;