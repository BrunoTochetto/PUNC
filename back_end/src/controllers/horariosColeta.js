async function listar(req, res){
  res.json({ mensagem: "Horários listados" });
};

async function criar(req, res){
  res.json({ mensagem: "Horário criado" });
};

async function editar(req, res){
  res.json({ mensagem: "Horário atualizado" });
};

export {listar, criar, editar}