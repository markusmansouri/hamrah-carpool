import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface CostCalculationRequest {
  bookingId: string;
  distance: number; // in kilometers
  duration: number; // in minutes
  passengers: number;
  isSharedRoute: boolean;
  promotionalCode?: string;
}

interface CostBreakdown {
  baseCost: number;
  timeCharge: number;
  distanceCharge: number;
  sharedRouteDiscount: number;
  promotionalDiscount: number;
  totalCostPerPassenger: number;
  totalCost: number;
  timestamp: string;
}

const PRICING_CONFIG = {
  baseRate: 2.0, // Base rate per trip (USD)
  distanceRate: 0.5, // Per km
  timeRate: 0.1, // Per minute
  sharedRouteDiscount: 0.15, // 15% discount for shared routes
  peakHourMultiplier: 1.25,
};

/**
 * Calculate cost breakdown for a booking
 */
export const calculateCost = functions.https.onCall(
  async (
    data: CostCalculationRequest,
    context
  ): Promise<CostBreakdown> => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Calculate charges
      const distanceCharge = data.distance * PRICING_CONFIG.distanceRate;
      const timeCharge = (data.duration / 60) * PRICING_CONFIG.timeRate; // Convert minutes to hours
      const baseCost = PRICING_CONFIG.baseRate;

      // Apply peak hour multiplier if applicable
      const hour = new Date().getHours();
      const isPeakHour = (hour >= 7 && hour < 9) || (hour >= 17 && hour < 19);
      const peakMultiplier = isPeakHour ? PRICING_CONFIG.peakHourMultiplier : 1.0;

      let subtotal =
        (baseCost + distanceCharge + timeCharge) * peakMultiplier;

      // Apply shared route discount
      let sharedRouteDiscount = 0;
      if (data.isSharedRoute) {
        sharedRouteDiscount = subtotal * PRICING_CONFIG.sharedRouteDiscount;
        subtotal -= sharedRouteDiscount;
      }

      // Apply promotional code if provided
      let promotionalDiscount = 0;
      if (data.promotionalCode) {
        const promoDoc = await db
          .collection('promotional_codes')
          .doc(data.promotionalCode)
          .get();

        if (promoDoc.exists) {
          const promo = promoDoc.data();
          if (promo && promo.active && promo.discountPercentage) {
            promotionalDiscount = subtotal * (promo.discountPercentage / 100);
            subtotal -= promotionalDiscount;
          }
        }
      }

      const totalCostPerPassenger = subtotal / data.passengers;
      const totalCost = subtotal;

      const breakdown: CostBreakdown = {
        baseCost,
        timeCharge,
        distanceCharge,
        sharedRouteDiscount,
        promotionalDiscount,
        totalCostPerPassenger: Math.round(totalCostPerPassenger * 100) / 100,
        totalCost: Math.round(totalCost * 100) / 100,
        timestamp: new Date().toISOString(),
      };

      // Store cost breakdown in Firestore
      await db.collection('cost_breakdowns').doc(data.bookingId).set(breakdown);

      // Update booking with cost information
      await db.collection('bookings').doc(data.bookingId).update({
        costPerPassenger: breakdown.totalCostPerPassenger,
        totalCost: breakdown.totalCost,
        costBreakdown: breakdown,
      });

      return breakdown;
    } catch (error) {
      console.error('Error calculating cost:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to calculate cost'
      );
    }
  }
);
