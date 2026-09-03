import functions from 'firebase-functions';
import admin from 'firebase-admin';
import { haversineDistance } from '../utils/geoUtils';
import { validateLocation, validateRequest } from '../utils/validationUtils';
import { getOrSetCache } from '../utils/firestoreUtils';

const db = admin.firestore();

interface ETARequest {
  origin: { latitude: number; longitude: number };
  destination: { latitude: number; longitude: number };
  passengers?: Array<{ latitude: number; longitude: number }>;
  timeOfDay?: string;
}

interface ETAResponse {
  estimatedMinutes: number;
  distance: number;
  route: Array<{ latitude: number; longitude: number }>;
  passengersETA?: number[];
}

export const etaCalculation = functions.https.onCall(
  async (data: ETARequest, context) => {
    try {
      if (!validateRequest(data, ['origin', 'destination'])) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
      }

      if (!validateLocation(data.origin) || !validateLocation(data.destination)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid location coordinates');
      }

      const cacheKey = `eta_${data.origin.latitude}_${data.origin.longitude}_${data.destination.latitude}_${data.destination.longitude}`;
      const cached = await getOrSetCache(cacheKey, null, 3600);

      if (cached) {
        return cached as ETAResponse;
      }

      const distance = haversineDistance(
        data.origin.latitude,
        data.origin.longitude,
        data.destination.latitude,
        data.destination.longitude
      );

      const baseTimeMinutes = (distance / 40) * 60;
      const hour = new Date().getHours();
      const isPeakHour = (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
      const peakMultiplier = isPeakHour ? 1.5 : 1.0;
      const adjustedTime = Math.round(baseTimeMinutes * peakMultiplier);

      const passengersETA = data.passengers
        ? data.passengers.map((passenger) => {
            const passengerDistance = haversineDistance(
              data.origin.latitude,
              data.origin.longitude,
              passenger.latitude,
              passenger.longitude
            );
            return Math.round((passengerDistance / 40) * 60 * peakMultiplier);
          })
        : undefined;

      const route = [
        data.origin,
        {
          latitude: (data.origin.latitude + data.destination.latitude) / 2,
          longitude: (data.origin.longitude + data.destination.longitude) / 2,
        },
        data.destination,
      ];

      const response: ETAResponse = {
        estimatedMinutes: adjustedTime,
        distance: parseFloat(distance.toFixed(2)),
        route,
        passengersETA,
      };

      await getOrSetCache(cacheKey, response, 3600);
      return response;
    } catch (error) {
      console.error('ETA calculation error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to calculate ETA');
    }
  }
);
