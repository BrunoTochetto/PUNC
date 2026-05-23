import { promises as fs } from 'node:fs';
import * as path from 'node:path';

// Caminho do diretório de logs
const logsDir = path.join(process.cwd(), '../logs');

// Auxiliares
async function criarDiretorioLogsSeNaoExistir() {
    try {
      await fs.mkdir(logsDir, { recursive: true });
    } catch (error) {
      console.error('Erro ao criar diretório de logs:', error.message);
    }
}


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
async function logErro(message, error = null, level = 'ERROR') {
    try {
      await criarDiretorioLogsSeNaoExistir();
      const agora = new Date();
      const timestamp = formatarDataHora(agora);
      
      let logMessage = `[${timestamp}] [${level}] ${message}`;
      
      if (error) {
          logMessage += `\n Tipo: ${error.name || 'Desconhecido'}`;
          logMessage += `\n Mensagem: ${error.message || 'Sem mensagem'}`;
          if (error.stack) {
            logMessage += `\n Stack Trace:\n${error.stack}`;
          }
      }
      
      logMessage += '\n' + '='.repeat(80) + '\n';

      // Escrever no arquivo de log
      const logFile = path.join(logsDir, 'log.txt');
      await fs.appendFile(logFile, logMessage, 'utf-8');

      // Também exibir no console
      console.log(logMessage);

    } catch (fileError) {
      console.error('Erro ao escrever no arquivo de log:', fileError.message);
    }
}

// Função auxiliar para outro tipos de logs
async function logAviso(message, error = null) {
    await logErro(message, error, 'WARNING');
}

async function logInfo(message) {

    await logErro(message, null, 'INFO');
}

export { logErro, logAviso, logInfo };