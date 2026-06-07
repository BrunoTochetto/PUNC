import { querry } from './querry.js';
import { logErro, logInfo } from './logErrors.js';
import { getMessaging, isFirebaseConfigurado } from './firebase.js';

class Notificacoes {
	static TOPICO_REGEX = /^[a-zA-Z0-9-_.~%]+$/;
	static PREFIXO_CELULA = 'celula';
	static TIPOS_LIXO = {
		ORGANICO: 'organico',
		RECICLADO: 'reciclado',
	};

	_topicosCriados = new Set();

	celulaParaTopico(celulaX, celulaY) {
		const topico = `${Notificacoes.PREFIXO_CELULA}_${celulaX}_${celulaY}`;
		this.validarTopico(topico);
		return topico;
	}

	validarTopico(topico) {
		if (typeof topico !== 'string' || !Notificacoes.TOPICO_REGEX.test(topico)) {
			throw new Error('Nome de tópico FCM inválido.');
		}
	}

	normalizarTipoLixo(tipoLixo) {
		const normalizado = tipoLixo.toString().toLowerCase().trim();

		if (['organico', 'orgânico', 'organica', 'orgânica'].includes(normalizado)) {
			return Notificacoes.TIPOS_LIXO.ORGANICO;
		}

		if (['reciclado', 'reciclavel', 'reciclável'].includes(normalizado)) {
			return Notificacoes.TIPOS_LIXO.RECICLADO;
		}

		throw new Error('tipo_lixo inválido. Use "organico" ou "reciclado".');
	}

	rotuloTipoLixo(tipoLixo) {
		const tipo = this.normalizarTipoLixo(tipoLixo);
		return tipo === Notificacoes.TIPOS_LIXO.ORGANICO ? 'orgânico' : 'reciclável';
	}

	montarPayloadColeta(tipoLixo, { titulo, corpo, dados = {} } = {}) {
		const tipo = this.normalizarTipoLixo(tipoLixo);
		const rotulo = this.rotuloTipoLixo(tipo);

		return {
			titulo: titulo ?? `Coleta de lixo ${rotulo}`,
			corpo: corpo ?? `O caminhão de coleta ${rotulo} está a caminho da sua região.`,
			dados: {
				evento: 'coleta_proxima',
				tipo_lixo: tipo,
				...dados,
			},
		};
	}

	_normalizarDados(dados = {}) {
		return Object.fromEntries(
			Object.entries(dados).map(([chave, valor]) => [chave, String(valor ?? '')])
		);
	}

	_montarMensagem(topico, { titulo, corpo, dados = {}, tipoLixo }) {
		this.validarTopico(topico);

		const payload = tipoLixo
			? this.montarPayloadColeta(tipoLixo, { titulo, corpo, dados })
			: { titulo, corpo, dados };

		if (!payload.titulo || !payload.corpo) {
			throw new Error('titulo e corpo são obrigatórios.');
		}

		return {
			topic: topico,
			notification: {
				title: payload.titulo,
				body: payload.corpo,
			},
			data: this._normalizarDados(payload.dados),
		};
	}

	async enviarTopico(topico, payload) {
		if (!isFirebaseConfigurado()) {
			return { enviado: false, motivo: 'firebase_nao_configurado' };
		}

		try {
			const messaging = getMessaging();
			const mensagem = this._montarMensagem(topico, payload);
			const messageId = await messaging.send(mensagem);

			logInfo(`Notificação enviada ao tópico ${topico}: ${messageId}`);
			return { enviado: true, topico, messageId };
		} catch (erro) {
			logErro(`Erro ao enviar notificação ao tópico ${topico}`, erro);
			throw erro;
		}
	}

	async enviarCelula(celulaX, celulaY, payload) {
		const topico = this.celulaParaTopico(celulaX, celulaY);
		return this.enviarTopico(topico, payload);
	}

	async criarTopicoCelula(celulaX, celulaY) {
		const topico = this.celulaParaTopico(celulaX, celulaY);

		if (this._topicosCriados.has(topico)) {
			return { topico, criado: false, motivo: 'topico_ja_registrado' };
		}

		if (!isFirebaseConfigurado()) {
			return { topico, criado: false, motivo: 'firebase_nao_configurado' };
		}

		try {
			const messaging = getMessaging();
			const messageId = await messaging.send({
				topic: topico,
				data: this._normalizarDados({
					evento: 'topico_criado',
					celula_x: celulaX,
					celula_y: celulaY,
				}),
			});

			this._topicosCriados.add(topico);
			logInfo(`Tópico FCM criado: ${topico} (${messageId})`);
			return { topico, criado: true, messageId };
		} catch (erro) {
			logErro(`Erro ao criar tópico FCM ${topico}`, erro);
			throw erro;
		}
	}

	async enviarTopicos(topicos, payload) {
		if (!Array.isArray(topicos) || topicos.length === 0) {
			throw new Error('Informe ao menos um tópico.');
		}

		if (!isFirebaseConfigurado()) {
			return { enviado: false, motivo: 'firebase_nao_configurado', resultados: [] };
		}

		const topicosUnicos = [...new Set(topicos.map((topico) => topico.trim()).filter(Boolean))];
		const messaging = getMessaging();
		const mensagens = topicosUnicos.map((topico) => this._montarMensagem(topico, payload));

		try {
			const resposta = await messaging.sendEach(mensagens);
			const resultados = topicosUnicos.map((topico, indice) => ({
				topico,
				enviado: resposta.responses[indice].success,
				messageId: resposta.responses[indice].messageId ?? null,
				erro: resposta.responses[indice].error?.message ?? null,
			}));

			logInfo(
				`Notificações por tópico: ${resposta.successCount} enviadas, ${resposta.failureCount} falhas.`
			);

			return {
				enviado: resposta.failureCount === 0,
				total: topicosUnicos.length,
				sucesso: resposta.successCount,
				falhas: resposta.failureCount,
				resultados,
			};
		} catch (erro) {
			logErro('Erro ao enviar notificações para múltiplos tópicos', erro);
			throw erro;
		}
	}

	async _buscarCelulasEmRaio(latitude, longitude, raioM, apenasComUsuarios = true) {
		const sql = `
			SELECT celula_x, celula_y, quantidade_usuarios
			FROM achar_celulas_em_raio($1, $2, $3)
			${apenasComUsuarios ? 'WHERE quantidade_usuarios > 0' : ''}
		`;

		const resultado = await querry(sql, [latitude, longitude, raioM]);
		return resultado.rows;
	}

	async notificarCelulasEmRaio(
		latitude,
		longitude,
		raioM,
		payload,
		{ apenasComUsuarios = true } = {}
	) {
		const celulas = await this._buscarCelulasEmRaio(latitude, longitude, raioM, apenasComUsuarios);
		const topicos = celulas.map(({ celula_x, celula_y }) => this.celulaParaTopico(celula_x, celula_y));

		if (topicos.length === 0) {
			return { enviado: false, motivo: 'nenhuma_celula_encontrada', resultados: [] };
		}

		const resposta = await this.enviarTopicos(topicos, payload);
		return { ...resposta, celulasNotificadas: celulas.length };
	}
}

const notificacoes = new Notificacoes();

export { Notificacoes, notificacoes };
