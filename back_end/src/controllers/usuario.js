import { querry } from '../services/querry.js';
import {Coordenadas} from '../models/coordenadas.js';
import {MACAddress} from'../models/macAddress.js';
import {CEP} from'../models/cep.js';
import { logErro, logAviso, logInfo } from '../services/logErrors.js';
import { notificacoes } from '../services/notificacoes.js';

/*
* [Recebe]: nome_dispositivo, mac, latitude, longitude
* [Retorna]: celula x, y e topico FCM (criado pelo back-end; inscrição no front-end)
*/
async function cadastro(req, res) {
	try {
		const { nome_dispositivo, mac, latitude, longitude } = req.body;

		if (!nome_dispositivo || !mac || latitude === undefined || longitude === undefined) {
			await logAviso('Cadastro de usuário: dados incompletos recebidos: ' + `nome dispostivo: ${nome_dispositivo}, mac: ${mac}, latitude e longitude: ${latitude, longitude}`, null);
			return res.status(400).json({ 
				erro: 'Dados incompletos... Tente novamento mais tarde.' 
			});
		}

		let macAddress;
		try {
			macAddress = new MACAddress(mac);
		} catch (err) {
			await logAviso(`Cadastro: MAC inválido - ${mac}`, err);
			return res.status(400).json({ erro: err.message });
		}

		let coordenadas;
		try {
			coordenadas = new Coordenadas(latitude, longitude);
		} catch (err) {
			await logAviso(`Cadastro: Coordenadas inválidas - lat: ${latitude}, lon: ${longitude}`, err);
			return res.status(400).json({ erro: err.message });
		}

		// Verificar se usuário com mesma MAC já existe
		const verificacao = await querry(
			'SELECT id FROM usuarios WHERE mac = $1',
			[macAddress.padrao]
		);

		if (verificacao.rows.length > 0) {
			await logAviso(
				`Cadastro: duplicação de MAC - ${macAddress.padrao} --- Possível tentativa de alterar a localização.`,
				null
			);
			return res.status(409).json({ erro: 'Usuário com este MAC já existe' });
		}
		//////////////

		const query = `
			INSERT INTO usuarios (nome_dispositivo, mac, geom)
			VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326))
			RETURNING id, id_celula, id_regiao
		`;

		const result = await querry(query, [
			nome_dispositivo,
			macAddress.padrao,
			coordenadas.longitude,
			coordenadas.latitude
		]);

		if (result.rows.length === 0) {
			const erro = new Error('Falha ao inserir usuário');
			await logAviso(`Registro do usuário: ${erro.message}`, erro);
		}

		const usuario = result.rows[0];
		
		// Buscar x e y da célula para o usuario ter e se cadastrar no FCM
		const queryCelula = `
			SELECT cell_x, cell_y FROM celulas WHERE id = $1
		`;
		const resultadoCelula = await querry(queryCelula, [usuario.id_celula]);
		const celula = resultadoCelula.rows[0] || { cell_x: null, cell_y: null };

		let topicoCelula = null;
		if (celula.cell_x != null && celula.cell_y != null) {
			try {
				const resultadoTopico = await notificacoes.criarTopicoCelula(celula.cell_x, celula.cell_y);
				topicoCelula = resultadoTopico.topico;
			} catch (err) {
				topicoCelula = notificacoes.celulaParaTopico(celula.cell_x, celula.cell_y);
				await logAviso(
					`Cadastro: falha ao criar tópico FCM da célula (${celula.cell_x}, ${celula.cell_y})`,
					err
				);
			}
		}
		
		await logInfo(
			`Usuário cadastrado: ID=${usuario.id}, MAC=${macAddress.padrao}, Device=${nome_dispositivo}, Célula(${celula.cell_x}, ${celula.cell_y}), Tópico=${topicoCelula ?? 'indisponível'}`
		);

		res.status(201).json({
			mensagem: 'Usuário cadastrado com sucesso',
			usuario: {
				id: usuario.id,
				id_celula: usuario.id_celula,
				id_regiao: usuario.id_regiao,
				celula: {
					x: celula.cell_x,
					y: celula.cell_y,
					topico: topicoCelula,
				}
			}
		});

	} catch (err) {
		await logErro('Erro ao cadastrar usuário', err);
		res.status(500).json({ 
			erro: 'Erro ao cadastrar usuário',
			detalhes: err.message 
		});
	}
}

export { cadastro };