export const cadastro = async (req, res) => {
  try {
    res.json({ mensagem: "Cadastro funcionando" });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
};