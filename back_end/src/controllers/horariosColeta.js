import { CEP } from '../services/dados.js';
import { querry } from '../models/querry.js';
import { logErro, logAviso, logInfo } from '../models/logErrors.js';
/*
* [Recebe]: CEP
* [Retorna]: Todos os horário da região com: horario_estimado, dia_semana, tipo_lixo, comentarios
*/
async function listar(req, res) {
  try {
    const { cep } = req.body;

    if (!cep) {
      await logAviso('Listar horarios de coleta: dados incompletos recebidos: ' + `cep: ${cep}`, null);
			return res.status(400).json({ 
				erro: 'CEP não informado.' 
			});
    };

    let cepOBJ;
    try {
			cepOBJ = new CEP(cep);
		} catch (err) {
			await logAviso(`Cadastro: CEP inválido - ${cep}`, err);
			return res.status(400).json({ erro: err.message });
		}

    const query = `
    SELECT horario_estimado, dia_semana, tipo_lixo, comentarios
    FROM vw_horarios_coleta
    WHERE cep LIKE '${cep}%'
    ORDER BY horario_estimado
    `;

    const resultado = await querry(query);

    // Verificar se gerente existe
    if (resultado.rows.length === 0) {
      await logAviso(`Sem nenhum horario estimado encontrado.`);
      return res.status(401).json({ 
        message: "Sem horario estimado registrado..." 
      });
    }

    const horarios = resultado.rows;

    // ! Transformar em obj



  } catch (e) {
    logErro("emPercurso", e);
  }
};

async function criar(req, res){
  res.json({ mensagem: "Horário criado" });
};

async function editar(req, res){
  res.json({ mensagem: "Horário atualizado" });
};

export {listar, criar, editar}