import jwt from 'jsonwebtoken';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';

async function autenticacaoNecessaria(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({ 
        erro: "Token de autenticação não fornecido" 
      });
    }

    const token = authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ 
        erro: "Formato de token inválido" 
      });
    }

    const decodificado = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'seu_segredo_super_secreto'
    );

    // Adicionar dados do usuário ao objeto request
    req.usuario = decodificado;
    next();
  } catch (erro) {
    if (erro.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        erro: "Token expirado" 
      });
    }
    
    if (erro.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        erro: "Token inválido" 
      });
    }


    res.status(500).json({ 
      erro: "Erro ao verificar autenticação" 
    });
  }
}

export { autenticacaoNecessaria };
