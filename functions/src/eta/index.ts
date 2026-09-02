import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';
import { validateBooking, validateCoordinates } from './validation';

const db = admin.firestore();

interface ETARequest {
  bookingId: string;
  pickupLocation: { latitude: number; longitude: number };
  dropoffLocation: { latitude: number; longitude: number };
  driverLocation: { latitude: number; longitude: number };
}

interface ETAResponse {
  bookingId: string;
  pickupETA: number;
  dropoffETA: number;
  distance: number;
  duration: number;
  timestamp: string;
}

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || '';
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

/**
 * Calculate ETA using Google Distance Matrix API
 */
export const calculateETA = functions.https.onCall(
  async (data: ETARequest, context): Promise<ETAResponse> => {
    try {
      // Validate authentication
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Validate input
      validateCoordinates(data.pickupLocation);
      validateCoordinates(data.dropoffLocation);
      validateCoordinates(data.driverLocation);

      // Check cache first
      const cacheDoc = await db
        .collection('eta_cache')
        .doc(data.bookingId)
        .get();

      if (cacheDoc.exists) {
        const cached = cacheDoc.data();
        if (
          cached &&
          Date.now() - cached.timestamp.toDate().getTime() < CACHE_DURATION
        ) {
          return {
            bookingId: data.bookingId,
            pickupETA: cached.pickupETA,
            dropoffETA: cached.dropoffETA,
            distance: cached.distance,
            duration: cached.duration,
            timestamp: new Date().toISOString(),
          };
        }
      }

      // Calculate ETA from driver to pickup
      const pickupETA = await calculateDistance(
        data.driverLocation,
        data.pickupLocation
      );

      // Calculate ETA from pickup to dropoff
      const dropoffETA = await calculateDistance(
        data.pickupLocation,
        data.dropoffLocation
      );

      const totalDuration = pickupETA.duration + dropoffETA.duration;
      const totalDistance = pickupETA.distance + dropoffETA.distance;

      // Cache the result
      await db.collection('eta_cache').doc(data.bookingId).set(
        {
          pickupETA: pickupETA.duration,
          dropoffETA: dropoffETA.duration,
          distance: totalDistance,
          duration: totalDuration,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      // Store in trip history
      await db.collection('eta_history').add({
        bookingId: data.bookingId,
        pickupETA: pickupETA.duration,
        dropoffETA: dropoffETA.duration,
        distance: totalDistance,
        duration: totalDuration,
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        bookingId: data.bookingId,
        pickupETA: pickupETA.duration,
        dropoffETA: dropoffETA.duration,
        distance: totalDistance,
        duration: totalDuration,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Error calculating ETA:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to calculate ETA'
      );
    }
  }
);

/**
 * Calculate distance and duration between two points using Google Maps API
 */
interface DistanceResult {
  distance: number; // in kilometers
  duration: number; // in minutes
}

async function calculateDistance(
  from: { latitude: number; longitude: number },
  to: { latitude: number; longitude: number }
): Promise<DistanceResult> {
  try {
    const response = await axios.get(
      'https://maps.googleapis.com/maps/api/distancematrix/json',
      {
        params: {
          origins: `${from.latitude},${from.longitude}`,
          destinations: `${to.latitude},${to.longitude}`,
          key: GOOGLE_MAPS_API_KEY,
          mode: 'driving',
          departure_time: Math.floor(Date.now() / 1000),
        },
      }
    );

    if (
      response.data.rows &&
      response.data.rows[0].elements &&
      response.data.rows[0].elements[0]
    ) {
      const element = response.data.rows[0].elements[0];
      if (element.status === 'OK') {
        return {
          distance: element.distance.value / 1000, // Convert to km
          duration: Math.ceil(element.duration.value / 60), // Convert to minutes
        };
      }
    }

    throw new Error('Invalid response from Google Maps API');
  } catch (error) {
    console.error('Error calling Google Maps API:', error);
    // Return fallback calculation using haversine formula
    return calculateHaversineDistance(from, to);
  }
}

/**
 * Fallback haversine distance calculation
 */
function calculateHaversineDistance(
  from: { latitude: number; longitude: number },
  to: { latitude: number; longitude: number }
): DistanceResult {
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
  const distance = R * c;
  const averageSpeed = 40; // km/h
  const duration = Math.ceil((distance / averageSpeed) * 60); // minutes

  return { distance, duration };
}
