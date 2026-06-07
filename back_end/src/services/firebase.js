import { readFileSync } from 'node:fs';
import admin from 'firebase-admin';
import { logAviso, logInfo } from './logErrors.js';

let firebaseApp = null;

function carregarCredencial() {
  try {
    const caminho = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (caminho) {
      const conteudo = readFileSync(caminho, 'utf8');
      return admin.credential.cert(JSON.parse(conteudo));
    }

    const jsonInline = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (jsonInline) {
      return admin.credential.cert(JSON.parse(jsonInline));
    }

    const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } = process.env;
    if (FIREBASE_PROJECT_ID && FIREBASE_CLIENT_EMAIL && FIREBASE_PRIVATE_KEY) {
      return admin.credential.cert({
        projectId: FIREBASE_PROJECT_ID,
        clientEmail: FIREBASE_CLIENT_EMAIL,
        privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      });
    }
  } catch (erro) {
    logAviso('Erro ao carregar credenciais do Firebase.', erro);
  }

  return null;
}

function initFirebase() {
  if (firebaseApp) {
    return firebaseApp;
  }

  const credencial = carregarCredencial();
  if (!credencial) {
    logAviso(
      'Firebase não configurado. Defina FIREBASE_SERVICE_ACCOUNT_PATH, FIREBASE_SERVICE_ACCOUNT ou FIREBASE_PROJECT_ID/FIREBASE_CLIENT_EMAIL/FIREBASE_PRIVATE_KEY.',
      null
    );
    return null;
  }

  firebaseApp = admin.initializeApp({ credential: credencial });
  logInfo('Firebase Admin inicializado.');
  return firebaseApp;
}

function isFirebaseConfigurado() {
  return Boolean(carregarCredencial());
}

function getMessaging() {
  const app = initFirebase();
  if (!app) {
    throw new Error('Firebase não está configurado.');
  }
  return admin.messaging();
}

export { initFirebase, isFirebaseConfigurado, getMessaging };
