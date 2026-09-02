import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

interface NotificationEvent {
  bookingId: string;
  type: 'pickup_reminder' | 'arrival' | 'trip_started' | 'trip_completed' | 'booking_accepted' | 'payment_confirmed';
  passengerId?: string;
  driverId?: string;
}

/**
 * Send pickup reminder notification when driver is 5 minutes away
 */
export const sendPickupReminder = functions.https.onCall(
  async (data: { bookingId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const bookingDoc = await db
        .collection('bookings')
        .doc(data.bookingId)
        .get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      const passengerId = booking.passengerId;

      // Get passenger's FCM token
      const userDoc = await db.collection('users').doc(passengerId).get();
      const user = userDoc.data();

      if (!user || !user.fcmToken) {
        throw new functions.https.HttpsError(
          'not-found',
          'FCM token not found'
        );
      }

      const message = {
        notification: {
          title: 'Driver Approaching',
          body: 'Your driver is 5 minutes away',
        },
        data: {
          bookingId: data.bookingId,
          type: 'pickup_reminder',
        },
        token: user.fcmToken,
      };

      await messaging.send(message);

      return { success: true };
    } catch (error) {
      console.error('Error sending pickup reminder:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send notification'
      );
    }
  }
);

/**
 * Send arrival notification when driver arrives (50m away)
 */
export const sendArrivalNotification = functions.https.onCall(
  async (data: { bookingId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const bookingDoc = await db
        .collection('bookings')
        .doc(data.bookingId)
        .get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      const passengerId = booking.passengerId;

      const userDoc = await db.collection('users').doc(passengerId).get();
      const user = userDoc.data();

      if (!user || !user.fcmToken) {
        return { success: false, message: 'FCM token not found' };
      }

      const message = {
        notification: {
          title: 'Driver Arrived',
          body: 'Your driver has arrived. Please come out now.',
        },
        data: {
          bookingId: data.bookingId,
          type: 'arrival',
        },
        token: user.fcmToken,
      };

      await messaging.send(message);
      return { success: true };
    } catch (error) {
      console.error('Error sending arrival notification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send notification'
      );
    }
  }
);

/**
 * Send trip completed notification
 */
export const sendTripCompletedNotification = functions.https.onCall(
  async (data: { bookingId: string; role: 'passenger' | 'driver' }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const bookingDoc = await db
        .collection('bookings')
        .doc(data.bookingId)
        .get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      const userId =
        data.role === 'passenger' ? booking.passengerId : booking.driverId;

      const userDoc = await db.collection('users').doc(userId).get();
      const user = userDoc.data();

      if (!user || !user.fcmToken) {
        return { success: false, message: 'FCM token not found' };
      }

      const message = {
        notification: {
          title: 'Trip Completed',
          body: `Your trip to ${booking.dropoffAddress} is complete. Cost: $${booking.totalCost}`,
        },
        data: {
          bookingId: data.bookingId,
          type: 'trip_completed',
        },
        token: user.fcmToken,
      };

      await messaging.send(message);
      return { success: true };
    } catch (error) {
      console.error('Error sending trip completed notification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send notification'
      );
    }
  }
);

/**
 * Send booking accepted notification
 */
export const sendBookingAcceptedNotification = functions.https.onCall(
  async (data: { bookingId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const bookingDoc = await db
        .collection('bookings')
        .doc(data.bookingId)
        .get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      const passengerId = booking.passengerId;

      const userDoc = await db.collection('users').doc(passengerId).get();
      const user = userDoc.data();

      if (!user || !user.fcmToken) {
        return { success: false, message: 'FCM token not found' };
      }

      const message = {
        notification: {
          title: 'Booking Accepted',
          body: 'Your booking has been accepted by the driver',
        },
        data: {
          bookingId: data.bookingId,
          type: 'booking_accepted',
        },
        token: user.fcmToken,
      };

      await messaging.send(message);
      return { success: true };
    } catch (error) {
      console.error('Error sending booking accepted notification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send notification'
      );
    }
  }
);
