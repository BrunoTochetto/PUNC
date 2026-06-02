import { logErro } from '../services/logErrors.js';
import { querry } from '../services/querry.js';

/*
* [Recebe]: id_gerente
* [Retorna]: Os motoristas e o status de percurso.
*/
async function ativos(req, res){
  try {
    const id_gerente = req.query.id_gerente || req.body.id_gerente;

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }

    const query = `
      SELECT
        m.id AS id_motorista,
        m.nome_dispositivo,
        m.mac,
        m.identificacao_caminhao,
        m.tipo_lixo,
        CASE
          WHEN EXISTS (
            SELECT 1 FROM trajetorias t
            WHERE t.id_motorista = m.id
            AND t.tempo_fim IS NULL
          ) THEN 'Em percurso'
          ELSE 'Inativo'
        END AS status
      FROM motoristas m
      WHERE m.id_gerente = $1
      ORDER BY m.id
    `;

    const resultado = await querry(query, [Number(id_gerente)]);
    return res.status(200).json({ motoristas: resultado.rows });
  } catch (e) {
    logErro('Erro ao listar motoristas ativos', e);
    res.status(500).json({ erro: 'Erro ao listar motoristas ativos.' });
  }
};

/*
* [Recebe]: id_motorista, novo status (Em percurso ou Inativo)
* [Retorna]: Mensagem de confirmação
*/
async function status(req, res){
  try {
    const id_gerente = req.usuario?.id || req.body.id_gerente;
    const id_motorista = Number(req.params.id);
    const novoStatus = (req.body.status || '').toString().trim();

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(400).json({ erro: 'ID do gerente inválido.' });
    }
    if (!id_motorista || Number.isNaN(id_motorista)) {
      return res.status(400).json({ erro: 'ID do motorista inválido.' });
    }
    if (!novoStatus) {
      return res.status(400).json({ erro: 'Status é obrigatório.' });
    }

    const motoristaQuery = `
      SELECT id, tipo_lixo FROM motoristas
      WHERE id = $1
      AND id_gerente = $2
    `;

    const motoristaResultado = await querry(motoristaQuery, [id_motorista, Number(id_gerente)]);
    if (motoristaResultado.rows.length === 0) {
      return res.status(404).json({ erro: 'Motorista não encontrado ou não autorizado.' });
    }

    const motorista = motoristaResultado.rows[0];
    const statusNormalized = novoStatus.toLowerCase();

    if (statusNormalized === 'em percurso' || statusNormalized === 'em_percurso' || statusNormalized === 'em-percurso') {
      const abertoQuery = `
        SELECT id FROM trajetorias
        WHERE id_motorista = $1
        AND tempo_fim IS NULL
        LIMIT 1
      `;
      const abertoResultado = await querry(abertoQuery, [id_motorista]);
      if (abertoResultado.rows.length > 0) {
        return res.status(409).json({ erro: 'Já existe um trajeto em andamento para este motorista.' });
      }

      const inserir = `
        INSERT INTO trajetorias (id_motorista, tipo_lixo)
        VALUES ($1, $2)
        RETURNING id, tempo_comeco
      `;
      const resultado = await querry(inserir, [id_motorista, motorista.tipo_lixo || null]);
      return res.status(201).json({ mensagem: 'Motorista em percurso.', trajetoria: resultado.rows[0] });
    }

    if (statusNormalized === 'inativo') {
      const fechar = `
        UPDATE trajetorias
        SET tempo_fim = NOW()
        WHERE id_motorista = $1
        AND tempo_fim IS NULL
        RETURNING id, tempo_comeco, tempo_fim
      `;
      const resultado = await querry(fechar, [id_motorista]);
      if (resultado.rows.length === 0) {
        return res.status(404).json({ erro: 'Nenhum trajeto em andamento encontrado para este motorista.' });
      }
      return res.status(200).json({ mensagem: 'Motorista marcado como inativo.', trajetoria: resultado.rows[0] });
    }

    return res.status(400).json({ erro: 'Status inválido. Use "Em percurso" ou "Inativo".' });
  } catch (e) {
    logErro('Erro ao atualizar status do motorista', e);
    res.status(500).json({ erro: 'Erro ao atualizar status do motorista.' });
  }
};

async function acharTodosEmRaio(req, res){
  try {
    const latitude = Number(req.body.latitude ?? req.query.latitude);
    const longitude = Number(req.body.longitude ?? req.query.longitude);
    const raioM = Number(req.body.raioM ?? req.query.raioM ?? 1000);

    if (Number.isNaN(latitude) || Number.isNaN(longitude) || Number.isNaN(raioM)) {
      return res.status(400).json({ erro: 'latitude, longitude e raioM são obrigatórios e devem ser numéricos.' });
    }

    const sql = `
      SELECT *
      FROM vw_localizacoes_de_trajetos
      WHERE tempo_fim IS NULL
      AND ST_DWithin(
        geom_3857,
        ST_Transform(ST_SetSRID(ST_MakePoint($1, $2), 4326), 3857),
        $3
      )
      ORDER BY tempo_comeco DESC
    `;

    const resultado = await querry(sql, [longitude, latitude, raioM]);
    return res.status(200).json({ localizacoes: resultado.rows });
  } catch (e) {
    logErro('Erro ao buscar motoristas em raio', e);
    res.status(500).json({ erro: 'Erro ao buscar motoristas em raio.' });
  }
}

export {ativos, status, acharTodosEmRaio}