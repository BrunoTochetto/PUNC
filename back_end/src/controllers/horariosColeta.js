import { querry } from '../services/querry.js';
import {Coordenadas} from '../models/coordenadas.js';
import {MACAddress} from'../models/macAddress.js';
import {CEP} from'../models/cep.js';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';

/*
* [Recebe]: CEP
* [Retorna]: Todos os horário da região com: horario_estimado, dia_semana, tipo_lixo, comentarios
*/
async function listar(req, res) {
  try {
    const { cep } = req.params;
    await logInfo(`Listar horarios de coleta: CEP recebido = ${cep}`);

    if (!cep) {
      await logAviso('Listar horarios de coleta: dados incompletos recebidos: ' + `cep: ${cep}`, null);
			return res.status(400).json({ 
				erro: 'CEP não informado.' 
			});
    };

    // Valida o CEP e limpa para apenas dígitos
    let cepLimpo;
    try {
      cepLimpo = new CEP(cep);
      if (!cepLimpo) {
        await logAviso(`Cadastro: CEP inválido - ${cep}`, null);
        return res.status(400).json({ erro: 'CEP inválido.' });
      }
    } catch (err) {
			await logAviso(`Cadastro: CEP inválido - ${cep}`, err);
			return res.status(400).json({ erro: err.message });
		}

    /*
     * Busca progressiva por prefixo:
     * A área de atuação armazena um CEP que pode ser parcial (ex: "897" para região ampla).
     * Comparamos: LEFT($1, LENGTH(a.cep)) = a.cep
     * Isso casa o CEP do usuário com qualquer nível de precisão da área.
     * Ex: cep do usuário = "89700123", a.cep = "897" → LEFT("89700123", 3) = "897" → match!
     */
    const query = `
    SELECT hc.horario_estimado, hc.dia_semana, hc.tipo_lixo, hc.comentarios, hc.ativo,
           a.cep AS cep_area
    FROM horarios_coleta hc
    JOIN area_de_atuacao a ON a.id = hc.id_area_atuacao
    WHERE LEFT($1, LENGTH(a.cep)) = a.cep
    AND hc.ativo = TRUE
    ORDER BY LENGTH(a.cep) DESC, hc.horario_estimado
    `;

    const resultado = await querry(query, [cepLimpo.value]);

    if (resultado.rows.length === 0) {
      await logAviso(`Nenhum horario encontrado para o CEP ${cepLimpo}.`);
      return res.status(200).json({ 
        message: "Nenhum horário encontrado para este CEP.",
        horarios: []
      });
    }

    res.status(200).json({
      message: resultado.rows.length + " horarios encontrados.",
      horarios: resultado.rows
    });

  } catch (e) {
    logErro("Listar horarios por CEP", e);
    res.status(500).json({ erro: 'Erro ao listar horários por CEP.' });
  }
};

/*
* [Recebe]: id gerente (automático), id_area_atuacao (deve ser listado no front), horario_estimado, dia_semana, data_criacao, tipo_lixo, comentários
* [Retorna]: Mensagem de confirmação de criação.
*/
async function criar(req, res){
  try {
    const { id_gerente, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios } = req.body;

    if (!id_area_atuacao || !horario_estimado || !dia_semana || !tipo_lixo) {
      const dados_recebidos = `${id_area_atuacao ? "id da area de atuação" : ""}, ${horario_estimado ? "Horario estimado" : ""}, ${dia_semana ? "Dia da semana" : ""}, ${tipo_lixo ? "Tipo de lixo" : ""}`
      const dados_faltando = `${id_area_atuacao ? "" : "id da area de atuação, "}, ${horario_estimado ? "" : "Horario estimado, "}${dia_semana ? "" : "Dia da semana, "}${tipo_lixo ? "" : "Tipo de lixo, "}`
      await logAviso('Criar horario de coleta: dados incompletos recebidos. \nDados recebidos: ' + dados_recebidos, + "\nDados faltando: " + dados_faltando, null);
      return res.status(400).json({
        erro: 'id_area_atuacao, horario_estimado, dia_semana e tipo_lixo são obrigatórios. Só recebido',
        recebido: dados_recebidos,
        faltando: dados_faltando
       });
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
      RETURNING id, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios, ativo, data_criacao
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
async function editar(req, res){
  try {
    const { id_gerente, id_horario, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios, ativo } = req.body;

    if (!id_horario || Number.isNaN(id_horario)) {
      return res.status(400).json({ erro: 'ID do horário inválido.' });
    }

    if (!horario_estimado && !dia_semana && !tipo_lixo && comentarios === undefined && id_area_atuacao === undefined && ativo === undefined) {
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
    if (ativo !== undefined) {
      campos.push('ativo');
      valores.push(ativo);
    }

    const atualizarHorario = `
      UPDATE horarios_coleta
      SET ${campos.map((campo, index) => `${campo} = $${index + 1}`).join(", ")}
      WHERE id = $${valores.length + 1}
      AND id_gerente = $${valores.length + 2}
      RETURNING id, id_area_atuacao, horario_estimado, dia_semana, tipo_lixo, comentarios, ativo, data_criacao
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

/*
* [Recebe]: id gerente
* [Retorna]: Todos os horários de coleta do gerente, incluindo os desativados
*/
// ! Não testado
async function listarPorGerente(req, res) {
  try {
    const id_gerente = req.query.id_gerente ?? req.body?.id_gerente;

    if (!id_gerente || Number.isNaN(id_gerente)) {
      await logAviso('Listar horários por gerente: ID do gerente inválido', null);
      return res.status(400).json({ 
        erro: 'ID do gerente inválido.' 
      });
    }

    const query = `
    SELECT id_horario, horario_estimado, dia_semana, tipo_lixo, comentarios, ativo, id_area_atuacao, cep, data_criacao
    FROM vw_horarios_coleta
    WHERE id_gerente = $1
    ORDER BY ativo DESC, horario_estimado
    `;

    const resultado = await querry(query, [id_gerente]);

    if (resultado.rows.length === 0) {
      await logAviso(`Listar horários por gerente: nenhum horário encontrado para o gerente ${id_gerente}`);
      return res.status(200).json({ 
        message: "Nenhum horário registrado para este gerente.",
        horarios: []
      });
    }

    res.status(200).json({
      message: resultado.rows.length + " horários encontrados.",
      horarios: resultado.rows
    });

  } catch (e) {
    logErro("Listar horarios por gerente", e);
    res.status(500).json({ erro: 'Erro ao listar horários do gerente.' });
  }
};

/*
* [Recebe]: id_gerente, id_horario
* [Retorna]: Mensagem de confirmação de exclusão.
*/
async function deletar(req, res) {
  try {
    const { id_gerente, id_horario } = req.body;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }
    if (!id_horario || Number.isNaN(Number(id_horario))) {
      return res.status(400).json({ erro: 'ID do horário inválido.' });
    }

    const resultado = await querry(
      `DELETE FROM horarios_coleta
       WHERE id = $1 AND id_gerente = $2
       RETURNING id`,
      [Number(id_horario), Number(id_gerente)],
    );

    if (resultado.rows.length === 0) {
      return res.status(404).json({ erro: 'Horário não encontrado ou não autorizado.' });
    }

    res.status(200).json({ mensagem: 'Horário excluído com sucesso.' });
  } catch (erro) {
    logErro('Excluir horario de coleta', erro);
    res.status(500).json({ erro: 'Erro ao excluir horário de coleta.' });
  }
}

export {listar, criar, editar, listarPorGerente, deletar}
