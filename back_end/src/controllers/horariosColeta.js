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

    res.status(302).json({
      message: resultado.rows.length + " horarios encontrados.",
      ...resultado.rows
    })



  } catch (e) {
    logErro("emPercurso", e);
  }
};

/*
* [Recebe]: id gerente (automático), id_area_atuacao (deve ser listado no front), horario_estimado, dia_semana, data_criacao, tipo_lixo, comentários
* [Retorna]: Mensagem de confirmação de criação.
*/
// ! Não testado
async function criar(req, res){
  try {
    const { id_gerente, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios } = req.body;

    if (!id_area_atuacao || !horario_estimado || !dia_semana || !tipo_lixo) {
      await logAviso('Criar horario de coleta: dados incompletos recebidos', null);
      return res.status(400).json({ erro: 'id_area_atuacao, horario_estimado, dia_semana e tipo_lixo são obrigatórios.' });
    }

    const verificarArea = `
      SELECT id
      FROM area_de_atuacao
      WHERE id = $1
      AND id_gerente = $2
    `;
    const areaResultado = await querry(verificarArea, [id_area_atuacao, id_gerente]);

    if (areaResultado.rows.length === 0) {
      await logAviso(`Criar horario de coleta: area_de_atuacao ${id_area_atuacao} não pertence ao gerente ${id_gerente}`, null);
      return res.status(403).json({ erro: 'Área de atuação inválida ou não autorizada.' });
    };

    const inserirHorario = `
      INSERT INTO horarios_coleta
        (id_gerente, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios)
      VALUES ($1, $2, $3, $4, $5, $6)
    `;

    const resultado = await querry(inserirHorario, [
      id_gerente,
      id_area_atuacao,
      horario_estimado,
      dia_semana,
      tipo_lixo,
      comentarios || null
    ]);

    res.status(201).json({
      mensagem: 'Horário criado com sucesso.',
      horario: resultado.rows[0]
    });
  } catch (erro) {
    logErro('Criar horario de coleta', erro);
    res.status(500).json({ erro: 'Erro ao criar horário de coleta.' });
  }
};

/*
* [Recebe]: id horarios de coleta, horario_estimado, dia_semana, data_criacao, tipo_lixo, comentários
* [Retorna]: Mensagem de confirmação de criação.
*/
// ! Não testado
async function editar(req, res){
  try {
    const { id_gerente, id_horario, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios } = req.body;

    if (!id_horario || Number.isNaN(id_horario)) {
      return res.status(400).json({ erro: 'ID do horário inválido.' });
    }

    if (!horario_estimado && !dia_semana && !tipo_lixo && !comentarios && !id_area_atuacao) {
      return res.status(400).json({ erro: 'Ao menos um campo deve ser informado para atualização.' });
    }

    if (id_area_atuacao !== undefined) {
      const verificarArea = `
        SELECT id
        FROM area_de_atuacao
        WHERE id = $1
        AND id_gerente = $2
      `;
      const areaResultado = await querry(verificarArea, [id_area_atuacao, id_gerente]);

      if (areaResultado.rows.length === 0) {
        await logAviso(`Editar horario de coleta: area_de_atuacao ${id_area_atuacao} não pertence ao gerente ${id_gerente}`, null);
        return res.status(403).json({ erro: 'Área de atuação inválida ou não autorizada.' });
      }
    }

    const campos = [];
    const valores = [];

    if (id_area_atuacao !== undefined) {
      campos.push('id_area_atuacao');
      valores.push(id_area_atuacao);
    }
    if (horario_estimado !== undefined) {
      campos.push('horario_estimado');
      valores.push(horario_estimado);
    }
    if (dia_semana !== undefined) {
      campos.push('dia_semana');
      valores.push(dia_semana);
    }
    if (tipo_lixo !== undefined) {
      campos.push('tipo_lixo');
      valores.push(tipo_lixo);
    }
    if (comentarios !== undefined) {
      campos.push('comentarios');
      valores.push(comentarios);
    }

    // Rever isso
    const atualizarHorario = `
      UPDATE horarios_coleta
      SET ${campos.map((campo, index) => `${campo} = $${index + 1}`).join(', ')}
      WHERE id = $${campos.length + 1}
      AND id_gerente = $${campos.length + 2}
      RETURNING id, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios, data_criacao
    `;

    const resultado = await querry(atualizarHorario, [...valores, id_horario, id_gerente]);

    if (resultado.rows.length === 0) {
      await logAviso(`Editar horario de coleta: horário ${id_horario} não encontrado ou não pertence ao gerente ${id_gerente}`, null);
      return res.status(404).json({ erro: 'Horário não encontrado ou não autorizado.' });
    }

    res.status(200).json({
      mensagem: 'Horário atualizado com sucesso.',
      horario: resultado.rows[0]
    });
  } catch (erro) {
    logErro('Editar horario de coleta', erro);
    res.status(500).json({ erro: 'Erro ao atualizar horário de coleta.' });
  }
};

export {listar, criar, editar}