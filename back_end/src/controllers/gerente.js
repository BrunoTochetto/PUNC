export const login = async (req, res) => {
  res.json({ mensagem: "Login funcionando" });
};

export const listarMotoristas = async (req, res) => {
  res.json({ mensagem: "Lista de motoristas" });
};

export const criarMotorista = async (req, res) => {
  res.json({ mensagem: "Motorista criado" });
};

export const deletarMotorista = async (req, res) => {
  res.json({ mensagem: "Motorista deletado" });
};

export const listarHorarios = async (req, res) => {
  res.json({ mensagem: "Horários listados" });
};

export const criarHorario = async (req, res) => {
  res.json({ mensagem: "Horário criado" });
};

export const editarHorario = async (req, res) => {
  res.json({ mensagem: "Horário atualizado" });
};