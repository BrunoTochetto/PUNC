import { logErro, logAviso, logInfo } from '../services/logErrors.js';

class CEP {
	constructor(cep) {
		const cepFormatado = CEP.isValido(cep);

		this.cep = cepFormatado ? cepFormatado : null;
		return cepFormatado;
	}

	static isValido(cep) {
		let cepSeparado = cep.replaceAll(' ', '').split('-');

		if (cepSeparado.length == 2) {
			if (cepSeparado[0].length < 5) {
				const erro = new Error(
					`Formato de CEP inválido: ${cep}. Use o formato 12345-123.`
				);
				logAviso(`CEP: ${erro.message}`, erro);
				return false
			}
			cepSeparado[0] += cepSeparado[1];
		}
		const cepFormatado = cepSeparado[0];

		if (cepFormatado.length > 8) {
			const erro = new Error(
				`Formato de CEP inválido: ${cep} - ${cepFormatado}. Use o formato 12345-123 ou menos, para menos precisão.`
			);
			logAviso(`CEP: ${erro.message}`, erro);
			return false
		};
		return cepFormatado;
	}

	get value() {
		return this.cep
	}
}

export {CEP}