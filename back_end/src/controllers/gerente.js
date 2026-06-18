import { querry } from '../services/querry.js';
import { CEP } from '../models/cep.js';
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

    if (resultado.rows.length === 0) {
      await logAviso(`Tentativa de login falhou: usuário "${email}" não encontrado`);
      return res.status(401).json({ 
        erro: "Usuário não encontrado ou Credenciais inválidas" 
      });
    }

    const gerente = resultado.rows[0];
    const senhaValida = await bcrypt.compare(senha, gerente.senha_criptografada);

    if (!senhaValida) {
      await logAviso(`Tentativa de login falhou: senha incorreta para usuário "${gerente.nome_usuario}" (ID: ${gerente.id})`);
      return res.status(401).json({ 
        erro: "Credenciais inválidas" 
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
      token
    });
  } catch (erro) {
    logErro('Erro ao fazer login', erro);
    res.status(500).json({ erro: "Erro ao realizar login" });
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
async function listarMotoristas(req, res){
  try {
    const { id_gerente } = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }

    const pegarMotoristas = `
      SELECT * FROM vw_motoristas_de_gerentes
      WHERE id_gerente = $1
      ORDER BY id_motorista
    `;

    const resultado = await querry(pegarMotoristas, [Number(id_gerente)]);
    return res.status(200).json({ motoristas: resultado.rows });
  } catch (e) {
    logErro("Erro na função listarMotoristas em gerente", e);
    res.status(500).json({ erro: 'Erro ao listar motoristas.' });
  }
};

/*
* [Recebe]: nome_dispositivo, mac, id_gerente
* [Retorna]: id (próprio), id_gerente
*/
async function criarMotorista(req, res){
  try {
    const { id_gerente, nome_dispositivo, mac } = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }

    if (!nome_dispositivo || !mac) {
      return res.status(400).json({ erro: 'Nome do dispositivo e MAC são obrigatórios.' });
    }

    const duplicado = await querry(
      'SELECT id FROM motoristas AND id_gerente = $2',
      [mac, Number(id_gerente)]
    );

    if (duplicado.rows.length > 0) {
      return res.status(409).json({ erro: 'Motorista com este MAC já cadastrado.' });
    }

    const inserirMotorista = `
      INSERT INTO motoristas (nome_dispositivo, mac, id_gerente)
      VALUES ($1, $2, $3)
      RETURNING id, nome_dispositivo, mac, id_gerente, data_criacao
    `;

    const resultado = await querry(inserirMotorista, [
      nome_dispositivo,
      mac,
      id_gerente,
    ]);

    res.status(201).json({ mensagem: 'Motorista criado com sucesso.', motorista: resultado.rows[0] });
  } catch (e) {
    logErro('Erro ao criar motorista', e);
    res.status(500).json({ erro: 'Erro ao criar motorista.' });
  }
};

/*
* [Recebe]: id_motorista, id_gerente (segurança)
* [Retorna]: Mensagem de confirmação
*/
async function deletarMotorista(req, res){
  try {
    
    const {id_gerente, id_motorista} = req.body;

    // # Creio que essas verificações não são necessárias pois serão enviadas pelo front sem o usuário saber. Então se der erro não tem muito o que corrigir.
    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }
    if (!id_motorista || Number.isNaN(Number(id_motorista))) {
      return res.status(400).json({ erro: 'ID do motorista inválido.' });
    }

    const deletarMotoristas = `
      DELETE FROM motoristas
      WHERE id = $1
      AND id_gerente = $2
      RETURNING id
    `;

    const resultado = await querry(deletarMotoristas, [Number(id_motorista), Number(id_gerente)]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({ erro: 'Motorista não encontrado ou não autorizado.' });
    }

    res.status(200).json({ message: 'Motorista deletado com sucesso.' });
  } catch (e) {
    logErro('Erro ao deletar motorista', e);
    res.status(500).json({ erro: 'Não foi possível deletar o motorista.' });
  }
};

// Areas de atuação
/*
* [Recebe]: id_gerente, FILTRO (cep) <- Front-end deve enviar sempre! Mesmo que esteja vazio
* [Retorna]: todos os dados da área de atuação.
*/
async function listarAreasAtuacao(req, res){
  try {

    const {id_gerente, cep} = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }

    let cepFormatado = '%';
    if (cep) {
      const validCep = new CEP(cep);
      if (!validCep) {
        return res.status(400).json({ erro: 'CEP inválido.' });
      }
      cepFormatado = `${validCep}%`;
    }

    const query = `
      SELECT * FROM area_de_atuacao
      WHERE id_gerente = $1
      AND cep LIKE $2
      ORDER BY cep
    `;

    const resultado = await querry(query, [Number(id_gerente), cepFormatado]);
    res.status(200).json({ areas: resultado.rows });
  } catch (e) {
    logErro('Erro ao listar áreas de atuação', e);
    res.status(500).json({ erro: 'Erro ao listar áreas de atuação.' });
  }
};

/*
* [Recebe]: id_gerente, cep
* [Retorna]: Mensagem de confirmação
*/
async function criarAreaAtuacao(req, res){
  try {
    const { cep, id_gerente } = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }
    if (!cep) {
      return res.status(400).json({ erro: 'CEP é obrigatório.' });
    }

    const validCep = new CEP(cep);
    if (!validCep) {
      return res.status(400).json({ erro: 'CEP inválido.' });
    }

    const verificarDuplicata = `
      SELECT id FROM area_de_atuacao
      WHERE id_gerente = $1
      AND cep = $2
    `;

    const duplicata = await querry(verificarDuplicata, [Number(id_gerente), validCep.value()]);
    if (duplicata.rows.length > 0) {
      return res.status(409).json({ mensagem: 'CEP já existe.' });
    }

    const criacao = `
      INSERT INTO area_de_atuacao (id_gerente, cep)
      VALUES ($1, $2)
      RETURNING id, id_gerente, cep
    `;

    const resultado = await querry(criacao, [Number(id_gerente), validCep.value()]);
    res.status(201).json({ mensagem: 'Área de atuação criada com sucesso.', area: resultado.rows[0] });
  } catch (e) {
    logErro('Erro ao criar área de atuação', e);
    res.status(500).json({ erro: 'Erro ao criar área de atuação.' });
  }
};

/*
* [Recebe]: id_area_atuacao, id_gerente (segurança)
* [Retorna]: Mensagem de confirmação
*/
async function deletarAreaAtuacao(req, res){
  try {
    
    const {id_area_atuacao, id_gerente} = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }
    if (!id_area_atuacao || Number.isNaN(Number(id_area_atuacao))) {
      return res.status(400).json({ erro: 'ID da área de atuação inválido.' });
    }

    const deletarArea = `
      DELETE FROM area_de_atuacao
      WHERE id = $1
      AND id_gerente = $2
      RETURNING id
    `;

    const resultado = await querry(deletarArea, [Number(id_area_atuacao), Number(id_gerente)]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({ erro: 'Área de atuação não encontrada ou não autorizada.' });
    }

    res.status(200).json({ message: 'Área de atuação deletada com sucesso.' });
  } catch (e) {
    logErro('Erro ao deletar área de atuação', e);
    res.status(500).json({ erro: 'Erro ao deletar área de atuação.' });
  }
};

export { deletarMotorista, criarMotorista, listarMotoristas, login, listarAreasAtuacao, criarAreaAtuacao, deletarAreaAtuacao }
