import { logErro, logAviso, logInfo } from '../services/logErrors.js';

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

export {MACAddress}