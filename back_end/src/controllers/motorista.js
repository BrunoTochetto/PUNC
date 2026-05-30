import {Coordenadas} from '../models/coordenadas.js';
import {MACAddress} from'../models/macAddress.js';
import {CEP} from'../models/cep.js';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';
import { querry } from '../services/querry.js';


/*
* [Recebe]: id_gerente, cep
* [Retorna]: Os motoristas
*/
async function ativos(req, res){
  res.json({ mensagem: "Motoristas ativos" });
};
/*
* [Recebe]: id_motorista, novo status (Em percurso ou Inativo)
* [Retorna]: Mensagem de confirmação
*/
async function status(req, res){
  res.json({ mensagem: "Status atualizado" });
};

// ! Testes
async function acharTodosEmRaio(latitude, longitude, raioM) {
  const sql = `
    SELECT * FROM achar_todos_em_raio($1, $2, $3);
  `;
  
  const values = [latitude, longitude, raioM];
  const { rows } = await pool.query(sql, values);

  return rows;
  // return montarHierarquia(rows, latitude, longitude, raioM);
}

export {ativos, status, acharTodosEmRaio}

// linha teste carol oi