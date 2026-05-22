async function login(req, res){
  res.json({ mensagem: "Login funcionando" });
};

async function listarMotoristas(req, res){
  res.json({ mensagem: "Lista de motoristas" });
};

async function criarMotorista(req, res){
  res.json({ mensagem: "Motorista criado" });
};

async function deletarMotorista(req, res){
  res.json({ mensagem: "Motorista deletado" });
};

export {deletarMotorista, criarMotorista, listarMotoristas, login}