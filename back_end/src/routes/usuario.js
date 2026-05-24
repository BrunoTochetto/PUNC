import express from 'express';
import * as controller from '../controllers/usuario.js';

const router = express.Router();

// Usuario
router.post('/cadastro', controller.cadastro);

export default router;