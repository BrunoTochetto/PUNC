export const ativos = async (req, res) => {
  res.json({ mensagem: "Motoristas ativos" });
};

export const status = async (req, res) => {
  res.json({ mensagem: "Status atualizado" });
};

export const emPercurso = async (req, res) => {
  res.json({ mensagem: "Motoristas em percurso" });
};