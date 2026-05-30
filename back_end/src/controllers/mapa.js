import {Coordenadas} from '../models/coordenadas.js';
import {MACAddress} from'../models/macAddress.js';
import {CEP} from'../models/cep.js';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';
import { querry } from '../services/querry.js';

/*
* [Recebe]: CEP
* [Retorna]: celula x e y para cadastro no FCM
*/
async function emPercurso(req, res) {
  try {
    const {cep} = req.body;

    res.status(400);
    return;

  } catch (e) {
    logErro("emPercurso", erro);
  }
};

export {emPercurso}