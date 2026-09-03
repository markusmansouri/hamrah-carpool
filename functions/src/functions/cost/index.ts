import functions from 'firebase-functions';
import admin from 'firebase-admin';
import { validateRequest } from '../utils/validationUtils';

const db = admin.firestore();

interface CostCalculationRequest {
  distance: number;
  passengers: number;
  timeOfDay: string;
  baseCostPerKm?: number;
  baseCostPerMinute?: number;
}

interface CostBreakdown {
  baseCost: number;
  peakHourMultiplier: number;
  passengerDiscount: number;
  costPerPassenger: number;
  totalCost: number;
}

const DEFAULT_BASE_COST_PER_KM = 0.5;
const DEFAULT_BASE_COST_PER_MINUTE = 0.1;

export const costCalculation = functions.https.onCall(
  async (data: CostCalculationRequest, context) => {
    try {
      if (!validateRequest(data, ['distance', 'passengers'])) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
      }

      if (data.distance < 0 || data.passengers < 1 || data.passengers > 4) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid distance or passenger count');
      }

      const baseCostPerKm = data.baseCostPerKm || DEFAULT_BASE_COST_PER_KM;
      const baseCostPerMinute = data.baseCostPerMinute || DEFAULT_BASE_COST_PER_MINUTE;
      const estimatedMinutes = (data.distance / 40) * 60;
      const baseCost = data.distance * baseCostPerKm + estimatedMinutes * baseCostPerMinute;

      const hour = new Date().getHours();
      const isPeakHour = (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
      const peakHourMultiplier = isPeakHour ? 1.25 : 1.0;
      const passengerDiscount = Math.max(0.7, 1.0 - (data.passengers - 1) * 0.1);

      const costPerPassenger = round(baseCost * peakHourMultiplier * passengerDiscount, 2);
      const totalCost = round(costPerPassenger * data.passengers, 2);

      const response: CostBreakdown = {
        baseCost: round(baseCost, 2),
        peakHourMultiplier,
        passengerDiscount,
        costPerPassenger,
        totalCost,
      };

      return response;
    } catch (error) {
      console.error('Cost calculation error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to calculate cost');
    }
  }
);

function round(value: number, decimals: number): number {
  return Math.round(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
}
