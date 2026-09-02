import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export * from './eta';
export * from './route';
export * from './cost';
export * from './delay';
export * from './notifications';
export * from './validation';

// Health check endpoint
export const healthCheck = functions.https.onRequest(async (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});
