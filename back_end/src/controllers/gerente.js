import { querry } from '../models/querry.js';
import { logErro, logAviso, logInfo } from '../models/logErrors.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

async function login(req, res){
  try {
    const { nome_usuario, senha } = req.body;
    // Criar uma coisa que: armazena o JWT token no banco, e quando tenta logar pega essa chave. Se já estiver expirando cria outra.
    if (!nome_usuario || !senha) {
      await logAviso(`Validação falhou: nome_usuario ou senha não fornecidos`);
      return res.status(400).json({ 
        erro: "Nome de usuário e senha são obrigatórios" 
      });
    }
    
    const resultado = await querry(
      'SELECT id, nome_usuario, senha_criptografada FROM gerentes WHERE nome_usuario = $1',
      [nome_usuario]
    );

    // Verificar se gerente existe
    if (resultado.rows.length === 0) {
      await logAviso(`Tentativa de login falhou: usuário "${nome_usuario}" não encontrado`);
      return res.status(401).json({ 
        erro: "Usuário não encontrado ou Credenciais inválidas" 
      });
    }

    const gerente = resultado.rows[0];

    const senhaValida = await bcrypt.compare(senha, gerente.senha_criptografada);
    
    if (!senhaValida) {
      await logAviso(`Tentativa de login falhou: senha incorreta para usuário "${nome_usuario}" (ID: ${gerente.id})`);
      return res.status(401).json({ 
        erro: "Credenciais inválidas" ,
      });
    }


    const token = jwt.sign(
      { id: gerente.id, nome_usuario: gerente.nome_usuario },
      process.env.JWT_SECRET || 'seu_segredo_super_secreto',
      { expiresIn: '1Y' }
    );

    res.json({ 
      mensagem: "Login realizado com sucesso",
      id: gerente.id,
      token: token,
    });
  } catch (erro) {
    await logErro('Erro ao fazer login', erro);
    res.status(500).json({ 
      erro: "Erro ao realizar login" 
    });
  }
};

// Função utilizada apenas para os devs devs
async function registrarGerente(nome, senha, email) {
  try {
    await logInfo(`Registrando novo gerente: ${nome}`);

    const senhaCriptografada = await bcrypt.hash(senha, 10);
    
    const resultado = await querry(
      'INSERT INTO gerentes (nome_usuario, senha_criptografada, email) VALUES ($1, $2, $3) RETURNING id, nome_usuario, email',
      [nome, senhaCriptografada, email]
    );

    const gerente = resultado.rows[0];
    await logInfo(`Gerente registrado com sucesso - ID: ${gerente.id}, Nome: ${gerente.nome_usuario}`);

    return { sucesso: true, gerente };
  } catch (erro) {
    await logErro(`Erro ao registrar gerente ${nome}`, erro);
    throw erro;
  }
}


async function listarMotoristas(req, res){
  res.json({ mensagem: "Lista de motoristas" });
};

async function criarMotorista(req, res){
  res.json({ mensagem: "Motorista criado" });
};

async function deletarMotorista(req, res){
  res.json({ mensagem: "Motorista deletado" });
};

export {deletarMotorista, criarMotorista, listarMotoristas, login}