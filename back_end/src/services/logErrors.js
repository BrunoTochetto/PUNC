import winston from 'winston';
import * as path from 'node:path';
import { fileURLToPath } from 'node:url';

// Caminho do diretório de logs
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const logsDir = path.join(__dirname, '../../logs');

// Função para gerar nome do arquivo de log com a data do dia
function gerarNomeArquivoLog(prefix = 'log') {
  const agora = new Date();
  const dia = String(agora.getDate()).padStart(2, '0');
  const mes = String(agora.getMonth() + 1).padStart(2, '0');
  const ano = agora.getFullYear();
  return `${prefix}-${ano}-${mes}-${dia}.log`;
}

// Configurar o logger com winston
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      let logMessage = `[${timestamp}] [${level.toUpperCase()}] ${message}`;
      
      // Se houver informações adicionais de erro, adicionar ao log
      if (meta.error) {
        logMessage += `\n Tipo: ${meta.error.name || 'Desconhecido'}`;
        logMessage += `\n Mensagem: ${meta.error.message || 'Sem mensagem'}`;
        if (meta.error.stack) {
          logMessage += `\n Stack Trace:\n${meta.error.stack}`;
        }
      }
      
      logMessage += '\n' + '='.repeat(80);
      return logMessage;
    })
  ),
  defaultMeta: { service: 'punc-api' },
  transports: [
    // Write all errors (level 'error' and below) to 'error-YYYY-MM-DD.log'
    new winston.transports.File({ 
      filename: path.join(logsDir, gerarNomeArquivoLog('error')), 
      level: 'error' 
    }),
    // Write all logs to 'log-YYYY-MM-DD.log'
    new winston.transports.File({ 
      filename: path.join(logsDir, gerarNomeArquivoLog('log')) 
    }),
  ],
});

// Se em desenvolvimento, também logar no console
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

// Auxiliares
function formatarDataHora(agora) {
    return agora.toLocaleString('pt-BR', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
}

// Função principal de log
function logErro(message, error = null, level = 'error') {
    try {
      const logData = error instanceof Error || error?.message || error?.stack
        ? { error }
        : {};

      logger.log(level, message, logData);
    } catch (fileError) {
      const detalheErro = fileError instanceof Error
        ? fileError.message
        : String(fileError);

      console.error('Erro ao escrever no arquivo de log:', detalheErro);
    }
}

// Função auxiliar para outros tipos de logs
function logAviso(message, error = null) {
    logErro(message, error, 'warn');
}

function logInfo(message) {
    logErro(message, null, 'info');
}

export { logErro, logAviso, logInfo, logger };