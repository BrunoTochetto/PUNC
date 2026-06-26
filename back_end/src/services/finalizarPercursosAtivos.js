import { querry } from './querry.js';
import { logErro, logInfo } from './logErrors.js';

/*
 * Finaliza todos os percursos (trajetorias) que ficaram abertos
 * após reinício ou queda do servidor (tempo_fim IS NULL).
 */
async function finalizarPercursosAtivos() {
  const resultado = await querry(
    `UPDATE trajetorias
     SET tempo_fim = NOW()
     WHERE tempo_fim IS NULL
     RETURNING id`
  );

  const quantidade = resultado.rowCount ?? resultado.rows.length;

  if (quantidade > 0) {
    logInfo(`${quantidade} percurso(s) ativo(s) finalizado(s) na inicialização do servidor.`);
  } else {
    logInfo('Nenhum percurso ativo pendente na inicialização do servidor.');
  }

  return quantidade;
}

export { finalizarPercursosAtivos };
