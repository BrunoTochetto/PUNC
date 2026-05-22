async function ativos(req, res){
  res.json({ mensagem: "Motoristas ativos" });
};

async function status(req, res){
  res.json({ mensagem: "Status atualizado" });
};

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