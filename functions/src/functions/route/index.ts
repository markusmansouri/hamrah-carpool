import functions from 'firebase-functions';
import admin from 'firebase-admin';
import { haversineDistance } from '../utils/geoUtils';
import { validateLocation, validateRequest } from '../utils/validationUtils';

const db = admin.firestore();

interface Location {
  latitude: number;
  longitude: number;
}

interface Passenger {
  id: string;
  location: Location;
  pickupAddress: string;
}

interface RouteOptimizationRequest {
  driverLocation: Location;
  destination: Location;
  passengers: Passenger[];
}

interface OptimizedRoute {
  orderedPassengers: Passenger[];
  totalDistance: number;
  estimatedDuration: number;
  polyline: Location[];
}

export const routeOptimization = functions.https.onCall(
  async (data: RouteOptimizationRequest, context) => {
    try {
      if (!validateRequest(data, ['driverLocation', 'destination', 'passengers'])) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
      }

      if (!Array.isArray(data.passengers) || data.passengers.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'No passengers provided');
      }

      if (data.passengers.length > 4) {
        throw new functions.https.HttpsError('invalid-argument', 'Maximum 4 passengers allowed');
      }

      if (
        !validateLocation(data.driverLocation) ||
        !validateLocation(data.destination) ||
        !data.passengers.every((p) => validateLocation(p.location))
      ) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid location coordinates');
      }

      const orderedPassengers = sortPassengersByProximity(
        data.driverLocation,
        data.destination,
        data.passengers
      );

      let totalDistance = 0;
      let currentLocation = data.driverLocation;
      const polyline: Location[] = [data.driverLocation];

      for (const passenger of orderedPassengers) {
        const distance = haversineDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          passenger.location.latitude,
          passenger.location.longitude
        );
        totalDistance += distance;
        polyline.push(passenger.location);
        currentLocation = passenger.location;
      }

      const finalDistance = haversineDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        data.destination.latitude,
        data.destination.longitude
      );
      totalDistance += finalDistance;
      polyline.push(data.destination);

      const estimatedDuration = Math.round((totalDistance / 40) * 60);

      const response: OptimizedRoute = {
        orderedPassengers,
        totalDistance: parseFloat(totalDistance.toFixed(2)),
        estimatedDuration,
        polyline,
      };

      return response;
    } catch (error) {
      console.error('Route optimization error:', error);
      throw new functions.https.HttpsError('internal', 'Failed to optimize route');
    }
  }
);

function sortPassengersByProximity(
  driverLocation: Location,
  destination: Location,
  passengers: Passenger[]
): Passenger[] {
  const sorted: Passenger[] = [];
  let current = driverLocation;
  const remaining = [...passengers];

  while (remaining.length > 0) {
    let nearest = remaining[0];
    let nearestIndex = 0;
    let minDistance = haversineDistance(
      current.latitude,
      current.longitude,
      remaining[0].location.latitude,
      remaining[0].location.longitude
    );

    for (let i = 1; i < remaining.length; i++) {
      const distance = haversineDistance(
        current.latitude,
        current.longitude,
        remaining[i].location.latitude,
        remaining[i].location.longitude
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = remaining[i];
        nearestIndex = i;
      }
    }

    sorted.push(nearest);
    remaining.splice(nearestIndex, 1);
    current = nearest.location;
  }

  return sorted;
}
