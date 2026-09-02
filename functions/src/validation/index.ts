/**
 * Validation utilities
 */

export interface Coordinates {
  latitude: number;
  longitude: number;
}

/**
 * Validate coordinates are within valid range
 */
export function validateCoordinates(coords: Coordinates): void {
  if (!coords || typeof coords.latitude !== 'number' || typeof coords.longitude !== 'number') {
    throw new Error('Invalid coordinates format');
  }

  if (coords.latitude < -90 || coords.latitude > 90) {
    throw new Error('Latitude must be between -90 and 90');
  }

  if (coords.longitude < -180 || coords.longitude > 180) {
    throw new Error('Longitude must be between -180 and 180');
  }
}

/**
 * Validate booking data
 */
export function validateBooking(booking: any): void {
  if (!booking.id || typeof booking.id !== 'string') {
    throw new Error('Invalid booking ID');
  }

  if (!booking.passengerId || typeof booking.passengerId !== 'string') {
    throw new Error('Invalid passenger ID');
  }

  if (!booking.driverId || typeof booking.driverId !== 'string') {
    throw new Error('Invalid driver ID');
  }

  validateCoordinates(booking.pickupLocation);
  validateCoordinates(booking.dropoffLocation);
}

/**
 * Validate GPS coordinates for spoofing detection
 */
export function validateGPSCoordinates(
  previousLocation: Coordinates,
  currentLocation: Coordinates,
  timeElapsedSeconds: number
): boolean {
  // Calculate maximum possible distance traveled at highway speed (120 km/h)
  const maxSpeedKmH = 120;
  const maxDistanceKm = (maxSpeedKmH / 3600) * timeElapsedSeconds;

  // Calculate actual distance
  const actualDistance = calculateHaversineDistance(
    previousLocation,
    currentLocation
  );

  // If actual distance > max possible distance, likely spoofed
  return actualDistance <= maxDistanceKm;
}

/**
 * Calculate haversine distance between two points
 */
function calculateHaversineDistance(
  from: Coordinates,
  to: Coordinates
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
