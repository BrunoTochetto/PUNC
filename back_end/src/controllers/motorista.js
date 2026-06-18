import { logErro, logAviso } from '../services/logErrors.js';
import { querry } from '../services/querry.js';
import { Coordenadas } from '../models/coordenadas.js';
import { MACAddress } from '../models/macAddress.js';

/*
* [Recebe]: id_gerente
* [Retorna]: Os motoristas e o status de percurso.
*/
async function ativos(req, res){
  try {
    const { id_gerente }= req.body;

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
* [Recebe]: id_motorista (param), status (Em percurso ou Inativo)
* [Retorna]: trajetoria criada ou finalizada
*
* Em percurso: abre uma nova linha em trajetorias (tempo_comeco = NOW).
*              As localizações serão gravadas em localizacao_trajetorias por outro endpoint.
* Inativo:    fecha a trajetoria aberta do motorista (tempo_fim = NOW).
*/
async function status(req, res){
  try {
    const id_gerente = req.usuario?.id;
    const id_motorista = Number(req.params.id);
    const statusSolicitado = _normalizarStatus((req.body.status || '').toString());

    if (!id_gerente || Number.isNaN(Number(id_gerente))) {
      return res.status(401).json({ erro: 'Gerente não autenticado.' });
    }
    if (!id_motorista || Number.isNaN(id_motorista)) {
      return res.status(400).json({ erro: 'ID do motorista inválido.' });
    }
    if (!statusSolicitado) {
      return res.status(400).json({ erro: 'Status é obrigatório.' });
    }

    const motoristaResultado = await querry(
      `SELECT id, tipo_lixo FROM motoristas WHERE id = $1 AND id_gerente = $2`,
      [id_motorista, Number(id_gerente)]
    );
    if (motoristaResultado.rows.length === 0) {
      return res.status(404).json({ erro: 'Motorista não encontrado ou não autorizado.' });
    }

    const { tipo_lixo } = motoristaResultado.rows[0];

    if (statusSolicitado === 'em percurso') {
      const trajetoriaAberta = await querry(
        `SELECT id FROM trajetorias WHERE id_motorista = $1 AND tempo_fim IS NULL LIMIT 1`,
        [id_motorista]
      );
      if (trajetoriaAberta.rows.length > 0) {
        return res.status(409).json({ erro: 'Já existe um trajeto em andamento para este motorista.' });
      }

      const resultado = await querry(
        `INSERT INTO trajetorias (id_motorista, tipo_lixo)
         VALUES ($1, $2)
         RETURNING id, id_motorista, tipo_lixo, tempo_comeco, tempo_fim`,
        [id_motorista, tipo_lixo || null]
      );
      return res.status(201).json({
        mensagem: 'Trajetória iniciada.',
        trajetoria: resultado.rows[0],
      });
    }

    if (statusSolicitado === 'inativo') {
      const resultado = await querry(
        `UPDATE trajetorias
         SET tempo_fim = NOW()
         WHERE id_motorista = $1
         AND tempo_fim IS NULL
         RETURNING id, id_motorista, tipo_lixo, tempo_comeco, tempo_fim`,
        [id_motorista]
      );
      if (resultado.rows.length === 0) {
        return res.status(404).json({ erro: 'Nenhum trajeto em andamento encontrado para este motorista.' });
      }
      return res.status(200).json({
        mensagem: 'Trajetória finalizada.',
        trajetoria: resultado.rows[0],
      });
    }

    return res.status(400).json({ erro: 'Status inválido. Use "Em percurso" ou "Inativo".' });
  } catch (e) {
    logErro('Erro ao atualizar status do motorista', e);
    res.status(500).json({ erro: 'Erro ao atualizar status do motorista.' });
  }

  function _normalizarStatus(status) {
    return status.toLowerCase().replace(/[_-]/g, ' ').trim();
  }
};

/*
* [Recebe]: id_motorista (param), mac, latitude, longitude
* [Retorna]: localização criada (vw_localizacoes_de_trajetos)
*/
async function localizacao(req, res){
  try {
    const id_motorista = Number(req.params.id);
    const { mac, latitude, longitude } = req.body;

    if (!id_motorista || Number.isNaN(id_motorista)) {
      return res.status(400).json({ erro: 'ID do motorista inválido.' });
    }
    if (!mac || latitude === undefined || longitude === undefined) {
      await logAviso(`Localização: dados incompletos - id_motorista: ${id_motorista}, mac: ${mac}`, null);
      return res.status(400).json({ erro: 'mac, latitude e longitude são obrigatórios.' });
    }

    let macAddress;
    try {
      macAddress = new MACAddress(mac);
    } catch (err) {
      await logAviso(`Localização: MAC inválido - ${mac}`, err);
      return res.status(400).json({ erro: err.message });
    }

    let coordenadas;
    try {
      coordenadas = new Coordenadas(latitude, longitude);
    } catch (err) {
      await logAviso(`Localização: coordenadas inválidas - lat: ${latitude}, lon: ${longitude}`, err);
      return res.status(400).json({ erro: err.message });
    }
    if (Number.isNaN(coordenadas.latitude) || Number.isNaN(coordenadas.longitude)) {
      return res.status(400).json({ erro: 'latitude e longitude devem ser numéricos.' });
    }

    const trajetoriaAberta = await querry(
      `SELECT t.id AS id_trajetoria
       FROM motoristas m
       JOIN trajetorias t ON t.id_motorista = m.id
       WHERE m.id = $1
       AND UPPER(REPLACE(REPLACE(m.mac, '-', ':'), ' ', '')) = $2
       AND t.tempo_fim IS NULL
       LIMIT 1`,
      [id_motorista, macAddress.padrao]
    );
    if (trajetoriaAberta.rows.length === 0) {
      return res.status(409).json({
        erro: 'Motorista não encontrado, MAC não confere ou não está em percurso.',
      });
    }

    const { id_trajetoria } = trajetoriaAberta.rows[0];
    const insercao = await querry(
      `INSERT INTO localizacao_trajetorias (id_trajetoria, geom_3857)
       VALUES ($1, ST_Transform(ST_SetSRID(ST_MakePoint($2, $3), 4326), 3857))
       RETURNING id`,
      [id_trajetoria, coordenadas.longitude, coordenadas.latitude]
    );

    const resultado = await querry(
      `SELECT * FROM vw_localizacoes_de_trajetos WHERE id_localizacao = $1`,
      [insercao.rows[0].id]
    );

    return res.status(201).json({
      mensagem: 'Localização registrada.',
      localizacao: resultado.rows[0],
    });
  } catch (e) {
    logErro('Erro ao registrar localização do motorista', e);
    res.status(500).json({ erro: 'Erro ao registrar localização do motorista.' });
  }
};


// ! Testes
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

export {ativos, status, localizacao, acharTodosEmRaio}