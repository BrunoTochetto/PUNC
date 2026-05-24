import { logErro } from "../models/logErrors.js";

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