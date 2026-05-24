import { logErro, logAviso, logInfo } from '../models/logErrors.js';
// Este arquivo contem os dados não-primitivos.

class MACAddress {
	static REGEX = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/; // Mágica da IA

	constructor(mac) {
		if (!mac || typeof mac !== 'string') {
			const erro = new Error('MAC deve ser uma string válida');
			logAviso(`MACAddress: ${erro.message}`, erro);
			throw erro;
		}

		const macFormatado = mac.trim().toUpperCase();
		
		if (!MACAddress.REGEX.test(macFormatado)) {
			const erro = new Error(
				`Formato de MAC inválido: ${mac}. Use o formato XX:XX:XX:XX:XX:XX ou XX-XX-XX-XX-XX-XX`
			);
			logAviso(`MACAddress: ${erro.message}`, erro);
			throw erro;
		}

		this.mac = macFormatado;
		logInfo(`MACAddress criada com sucesso: ${macFormatado}`);
	}

	get valor() {
	  return this.mac;
	}

	/**
	 * Retorna a MAC com dois pontos
	 */
	get padrao() {
	  return this.mac.replace(/-/g, ':');
	}

	static isValido(mac) {
	  try {
		  new MACAddress(mac);
		  return true;
	  } catch {
		  return false;
	  }
	}

	toString() {
	  return this.mac;
	}

	toJSON() {
	  return this.mac;
	}
}

class Coordenadas {
	constructor(latitude, longitude) {
		this.latitude = Number(latitude);
		this.longitude = Number(longitude);
		logInfo(`Coordenadas criadas com sucesso: lat=${this.latitude}, lon=${this.longitude}`);
	}

	/**
	 * Retorna as coordenadas em formato WKT (Well-Known Text)
	 */
	get wkt() {
	  	return `POINT(${this.longitude} ${this.latitude})`;
	}

	toJSON() {
		return {
			latitude: this.latitude,
			longitude: this.longitude
		};
	}
}

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


export { MACAddress, Coordenadas, CEP };