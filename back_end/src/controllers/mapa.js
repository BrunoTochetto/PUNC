import { logErro } from '../services/logErrors.js';
import { querry } from '../services/querry.js';

/*
* [Recebe]: opcional id_gerente
* [Retorna]: motoristas em percurso com a última localização disponível.
*/
async function emPercurso(req, res) {
  try {
    const id_gerente = req.params.id_gerente ? Number(req.params.id_gerente) : undefined;

    let sql = `
      SELECT *
      FROM vw_localizacoes_de_trajetos
      WHERE id_trajetoria IN (
        SELECT id FROM trajetorias WHERE tempo_fim IS NULL
      )
    `;
    const values = [];

    if (id_gerente !== undefined) {
      if (Number.isNaN(id_gerente)) {
        return res.status(400).json({ erro: 'ID do gerente inválido.' });
      }
      sql += ` AND id_gerente = $1`;
      values.push(id_gerente);
    }

    sql += 'ORDER BY tempo_comeco DESC';

    const resultado = await querry(sql, values);
    return res.status(200).json({ trajetosEmPercurso: resultado.rows });
  } catch (erro) {
    logErro('Erro ao buscar percurso em mapa', erro);
    res.status(500).json({ erro: 'Erro ao buscar trajetos em percurso.' });
  }
};

export {emPercurso}