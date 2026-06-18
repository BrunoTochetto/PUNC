import { logErro, logAviso, logInfo } from '../services/logErrors.js';

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

export {Coordenadas}