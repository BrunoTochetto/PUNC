import { querry } from '../services/querry.js';
import {Coordenadas} from '../models/coordenadas.js';
import {MACAddress} from'../models/macAddress.js';
import {CEP} from'../models/cep.js';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

/*
* [Recebe]: email e senha
* [Retorna]: id_gerente e token jwt
*/
async function login(req, res){
  try {
    const { email, senha } = req.body;
    // Criar uma coisa que: armazena o JWT token no banco, e quando tenta logar pega essa chave. Se já estiver expirando cria outra.
    if (!email || !senha) {
      await logAviso(`Validação falhou: email ou senha não fornecidos`);
      return res.status(400).json({ 
        erro: "Email e senha são obrigatórios" 
      });
    }
    
    const resultado = await querry(
      'SELECT id, nome_usuario, email, senha_criptografada FROM gerentes WHERE email = $1',
      [email.toLowerCase()]
    );

    // Verificar se gerente existe
    if (resultado.rows.length === 0) {
      await logAviso(`Tentativa de login falhou: usuário "${email}" não encontrado`);
      return res.status(401).json({ 
        erro: "Usuário não encontrado ou Credenciais inválidas" 
      });
    }

    const gerente = resultado.rows[0];
    const nome_usuario = gerente.nome_usuario;

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

    res.status(202).json({ 
      mensagem: "Login realizado com sucesso",
      id: gerente.id,
      nome: gerente.nome_usuario,
      token: token
    });
  } catch (erro) {
    logErro('Erro ao fazer login', erro);
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
  }
}

// registrarGerente('Bruno', '123', 'drag@isada.com');

// Motoristas
/*
* [Recebe]: id_gerente
* [Retorna]: todos os dados dos motoristas.
*/
// ! Não testado
async function listarMotoristas(req, res){
  try {
    const { id_gerente } = req.body;

    const pegarMotoristas = `
    SELECT * FROM vw_motoristas_de_gerentes
    WHERE id_gerente = $1
    `

    const resultado = await querry(pegarMotoristas, [id_gerente]);

    if (resultado.rows.length == 0) {
      res.status(204).json({message: "Nenhum motorista registrado encontrado..."})
      throw new Error("Nenhum motorista para este gerente encontrado.")
    };

    res.status(200).json({
      ...resultado.rows
    });

  } catch (e) {
    logErro("Erro na função listarMotoristas em gerente: ", e)
  }
};

/*
* [Recebe]: nome_dispositivo, mac, id_gerente
* [Retorna]: id (próprio), id_gerente
* Seria bom ter uma autenticação específica para o caminhoneiro, usando o JWT
*/
async function criarMotorista(req, res){
  res.json({ mensagem: "Motorista criado" });
};
/*
* [Recebe]: id_motorista, id_gerente (segurança)
* [Retorna]: Mensagem de confirmação
*/
// ! Não testado
async function deletarMotorista(req, res){
  try {
    const { id_motorista, id_gerente } = req.body;

    const deletarMotoristas = `
    DELETE FROM motoristas
    WHERE id = $1
    AND id_gerente = $2
    `

    await querry(deletarMotoristas, [id_motorista, id_gerente]);

    res.status(200).json({
      message: "Deletado com sucesso"
    });

  } catch (e) {
    res.status(400).res({
      message: "Não foi possível deletar o motorista.",
      error: e
    });
    logErro("Erro na função listarMotoristas em gerente: ", e)
  }
};

// Areas de atuação
/*
* [Recebe]: id_gerente, FILTRO (cep) <- Front-end deve enviar sempre! Mesmo que esteja vazio
* [Retorna]: todos os dados da área de atuação.
*/
// ! Não testado
async function listarAreasAtuacao(req, res){
   try {
    const { id_gerente, cep } = req.body;

    const areas = `
      SELECT * FROM area_de_atuacao
      WHERE id_gerente = ${id_gerente}
      AND cep LIKE '${cep || "%"}'`;

    const resultado = await querry(areas);
    const rows = resultado.rows;
    console.log(rows);


    res.status(201).json({ rows });

  } catch (e) {
    logErro("Criar area de atuação:", e);
    res.status(400);
  }
};


/*
* [Recebe]: id_gerente, cep
* [Retorna]: Mensagem de confirmação
*/
// ! Não testado
async function criarAreaAtuacao(req, res){
  try {
    const { id_gerente, cep } = req.body;

    try {
      const verificarDuplicata = `
        SELECT * FROM area_de_atuacao
        WHERE id_gerente = ${id_gerente}
        AND cep = '${cep}'`;

      const resultado = await querry(verificarDuplicata);

      if (resultado.rows.length != 0) {
        logAviso("CEP já existe", null);
        return res.status(409).json({message: "CEP já existe."});
      }
    } catch (e) {
      logErro("verificar duplicata area atuação: ", e);
    }
   
    const criacao = `
    INSERT INTO area_de_atuacao (id_gerente, cep)
    VALUES ( $1, $2 )
    `
    await querry(criacao, [id_gerente, cep]);

    res.status(201).json({ mensagem: "Area de atuação criado" });
  } catch (e) {
    logErro("Criar area de atuação:", e);
    res.status(400);
  }
};
/*
* [Recebe]: id (próprio), id_gerente (segurança)
* [Retorna]: Mensagem de confirmação
*/
// ! Não testado
async function deletarAreaAtuacao(req, res){
  try {
    const { id_area_atuacao, id_gerente } = req.body;

    const deletarMotoristas = `
    DELETE FROM area_de_atuacao
    WHERE id = $1
    AND id_gerente = $2
    `

    await querry(deletarMotoristas, [ id_area_atuacao, id_gerente]);

    res.status(200).json({
      message: "Deletado com sucesso"
    });

  } catch (e) {
    res.status(400).res({
      message: "Não foi possível deletar o motorista.",
      error: e
    });
    logErro("Erro na função listarMotoristas em gerente: ", e)
  }
};

export {deletarMotorista, criarMotorista, listarMotoristas, login, listarAreasAtuacao, criarAreaAtuacao, deletarAreaAtuacao}