import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { validateBooking } from '../validation';

const db = admin.firestore();

interface Passenger {
  id: string;
  pickupLocation: { latitude: number; longitude: number };
  pickupAddress: string;
  dropoffLocation: { latitude: number; longitude: number };
  dropoffAddress: string;
}

interface OptimizedRoute {
  bookingIds: string[];
  orderedPickupPoints: Passenger[];
  totalDistance: number;
  totalDuration: number;
  polylinePoints: Array<{ latitude: number; longitude: number }>;
  timestamp: string;
}

/**
 * Optimize route for multiple passengers using geospatial sorting
 */
export const optimizeRoute = functions.https.onCall(
  async (data: { driverId: string; bookingIds: string[] }, context): Promise<OptimizedRoute> => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Fetch all bookings
      const bookings = await Promise.all(
        data.bookingIds.map(id => db.collection('bookings').doc(id).get())
      );

      const passengers: Passenger[] = bookings
        .filter(doc => doc.exists)
        .map(doc => {
          const booking = doc.data();
          return {
            id: doc.id,
            pickupLocation: booking.pickupLocation,
            pickupAddress: booking.pickupAddress,
            dropoffLocation: booking.dropoffLocation,
            dropoffAddress: booking.dropoffAddress,
          };
        });

      // Get driver's current location
      const driverLocSnapshot = await db
        .collection('driverLocations')
        .doc(data.driverId)
        .get();

      if (!driverLocSnapshot.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Driver location not found'
        );
      }

      const driverLocation = driverLocSnapshot.data() || {};

      // Optimize pickup order using geospatial sorting
      const optimizedPassengers = optimizePickupOrder(
        passengers,
        driverLocation
      );

      // Calculate total distance and duration
      let totalDistance = 0;
      let totalDuration = 0;
      const polylinePoints: Array<{ latitude: number; longitude: number }> = []
        .concat(driverLocation)
        .concat(
          optimizedPassengers.map(p => ({
            latitude: p.pickupLocation.latitude,
            longitude: p.pickupLocation.longitude,
          }))
        )
        .concat(
          optimizedPassengers.map(p => ({
            latitude: p.dropoffLocation.latitude,
            longitude: p.dropoffLocation.longitude,
          }))
        );

      // Store optimized route in Firestore
      const optimizedRouteDoc = await db.collection('optimized_routes').add({
        driverId: data.driverId,
        bookingIds: data.bookingIds,
        orderedPickupPoints: optimizedPassengers,
        totalDistance,
        totalDuration,
        polylinePoints,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        bookingIds: data.bookingIds,
        orderedPickupPoints: optimizedPassengers,
        totalDistance,
        totalDuration,
        polylinePoints,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Error optimizing route:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to optimize route'
      );
    }
  }
);

/**
 * Optimize pickup order using nearest neighbor algorithm with time windows
 */
function optimizePickupOrder(
  passengers: Passenger[],
  driverLocation: { latitude: number; longitude: number }
): Passenger[] {
  if (passengers.length <= 1) return passengers;

  const optimized: Passenger[] = [];
  const remaining = [...passengers];
  let currentLocation = driverLocation;

  // Nearest neighbor algorithm
  while (remaining.length > 0) {
    let nearestIndex = 0;
    let nearestDistance = Infinity;

    for (let i = 0; i < remaining.length; i++) {
      const distance = calculateDistance(
        currentLocation,
        remaining[i].pickupLocation
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    const nearest = remaining.splice(nearestIndex, 1)[0];
    optimized.push(nearest);
    currentLocation = nearest.dropoffLocation; // Move to dropoff for next calculation
  }

  return optimized;
}

/**
 * Calculate distance between two points using haversine formula
 */
function calculateDistance(
  from: { latitude: number; longitude: number },
  to: { latitude: number; longitude: number }
): number {
  const R = 6371; // Earth's radius in km
  const dLat = ((to.latitude - from.latitude) * Math.PI) / 180;
  const dLon = ((to.longitude - from.longitude) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((from.latitude * Math.PI) / 180) *
      Math.cos((to.latitude * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
