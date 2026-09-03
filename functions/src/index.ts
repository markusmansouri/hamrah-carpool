import functions from 'firebase-functions';
import admin from 'firebase-admin';

admin.initializeApp();

export { etaCalculation } from './functions/eta';
export { routeOptimization } from './functions/route';
export { costCalculation } from './functions/cost';
export { delayDetection } from './functions/delay';
export { notificationTriggers } from './functions/notifications';
