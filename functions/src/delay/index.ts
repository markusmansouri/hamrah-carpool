import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const realtimeDb = admin.database();

interface DelayAlert {
  driverId: string;
  bookingId: string;
  delayMinutes: number;
  reason: string;
  timestamp: string;
}

const DELAY_THRESHOLD_MINUTES = 5;
const SPEED_THRESHOLD_KMH = 5; // Considered stopped if below this speed

/**
 * Monitor driver location and detect delays
 * Triggered when driver location updates in Realtime Database
 */
export const detectDelay = functions.database
  .ref('driverLocations/{driverId}')
  .onUpdate(async (change, context) => {
    try {
      const driverId = context.params.driverId;
      const currentLocation = change.after.val();
      const previousLocation = change.before.val();

      if (!currentLocation || !previousLocation) {
        return;
      }

      // Get driver's active bookings
      const bookingsSnapshot = await db
        .collection('bookings')
        .where('driverId', '==', driverId)
        .where('status', 'in', ['inProgress', 'driverArrived'])
        .get();

      for (const bookingDoc of bookingsSnapshot.docs) {
        const booking = bookingDoc.data();
        const estimatedPickupTime = booking.estimatedPickupTime.toDate();
        const currentTime = new Date();
        const delayMinutes = Math.floor(
          (currentTime.getTime() - estimatedPickupTime.getTime()) / (1000 * 60)
        );

        if (delayMinutes > DELAY_THRESHOLD_MINUTES) {
          // Check if driver is actually moving
          const speed = currentLocation.speed || 0;
          let reason = 'Unknown';

          if (speed < SPEED_THRESHOLD_KMH) {
            reason = `Driver stopped for ${delayMinutes} minutes`;
          } else {
            reason = `Estimated arrival time exceeded by ${delayMinutes} minutes`;
          }

          // Create delay alert
          const alert: DelayAlert = {
            driverId,
            bookingId: bookingDoc.id,
            delayMinutes,
            reason,
            timestamp: new Date().toISOString(),
          };

          // Store in Firestore
          await db.collection('delay_alerts').add(alert);

          // Send notification to passenger
          await sendDelayNotification(
            bookingDoc.id,
            booking.passengerId,
            delayMinutes
          );

          // Update booking status
          await db.collection('bookings').doc(bookingDoc.id).update({
            delayAlert: alert,
            lastDelayNotificationTime:
              admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (error) {
      console.error('Error detecting delay:', error);
    }
  });

/**
 * Send delay notification to passenger
 */
async function sendDelayNotification(
  bookingId: string,
  passengerId: string,
  delayMinutes: number
): Promise<void> {
  try {
    // Get passenger's FCM token
    const userDoc = await db.collection('users').doc(passengerId).get();
    const user = userDoc.data();

    if (!user || !user.fcmToken) {
      console.log('FCM token not found for user:', passengerId);
      return;
    }

    const message = {
      notification: {
        title: 'Driver Delayed',
        body: `Your driver is running ${delayMinutes} minutes late`,
      },
      data: {
        bookingId,
        delayMinutes: delayMinutes.toString(),
      },
      token: user.fcmToken,
    };

    await admin.messaging().send(message);
  } catch (error) {
    console.error('Error sending delay notification:', error);
  }
}
