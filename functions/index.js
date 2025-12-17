const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Scheduled function to reset leave balances every January 1st at 00:00 UTC
 * Runs automatically using Cloud Scheduler
 * Cron expression: "0 0 1 1 *" means "At 00:00 on day 1 of January"
 */
exports.resetYearlyLeaveQuotas = functions.pubsub
    .schedule('0 0 1 1 *')
    .timeZone('UTC')
    .onRun(async (context) => {
        const db = admin.firestore();
        const currentYear = new Date().getFullYear();

        console.log(`Starting yearly leave quota reset for year ${currentYear}`);

        try {
            // Default leave quotas (update these if needed)
            const SICK_LEAVE_YEARLY = 12;
            const PAID_LEAVE_YEARLY = 20;

            // Get all users
            const usersSnapshot = await db.collection('users').get();

            if (usersSnapshot.empty) {
                console.log('No users found to reset leave quotas');
                return null;
            }

            // Batch write for efficiency
            const batch = db.batch();
            let processedCount = 0;

            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();

                // Skip inactive users
                if (!userData.is_active) {
                    console.log(`Skipping inactive user: ${userId}`);
                    continue;
                }

                // Create new leave balance document for the new year
                const leaveBalanceRef = db.collection('leave_balances').doc();

                const newLeaveBalance = {
                    user_id: userId,
                    year: currentYear,
                    sick_leave: {
                        total: SICK_LEAVE_YEARLY,
                        used: 0,
                        remaining: SICK_LEAVE_YEARLY
                    },
                    paid_leave: {
                        total: PAID_LEAVE_YEARLY,
                        used: 0,
                        remaining: PAID_LEAVE_YEARLY
                    },
                    monthly_usage: {},
                    updated_at: admin.firestore.FieldValue.serverTimestamp()
                };

                batch.set(leaveBalanceRef, newLeaveBalance);
                processedCount++;

                // Firestore batch has a limit of 500 operations
                // Commit and start new batch if needed
                if (processedCount % 500 === 0) {
                    await batch.commit();
                    console.log(`Committed batch of 500 leave balance resets`);
                }
            }

            // Commit any remaining operations
            if (processedCount % 500 !== 0) {
                await batch.commit();
            }

            console.log(`Successfully reset leave quotas for ${processedCount} users for year ${currentYear}`);

            // Log the reset event
            await db.collection('system_logs').add({
                event: 'yearly_leave_quota_reset',
                year: currentYear,
                users_processed: processedCount,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            return { success: true, usersProcessed: processedCount };

        } catch (error) {
            console.error('Error resetting yearly leave quotas:', error);

            // Log the error
            await db.collection('system_logs').add({
                event: 'yearly_leave_quota_reset_error',
                year: currentYear,
                error: error.message,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            throw error;
        }
    });

/**
 * Manual trigger function for testing or emergency reset
 * Call this function manually from Firebase Console or CLI if needed
 */
exports.manualResetLeaveQuotas = functions.https.onCall(async (data, context) => {
    // Verify the caller is a super admin
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const db = admin.firestore();
    const callerDoc = await db.collection('users').doc(context.auth.uid).get();

    if (!callerDoc.exists || callerDoc.data().role !== 'super_admin') {
        throw new functions.https.HttpsError('permission-denied', 'Only super admins can manually reset leave quotas');
    }

    const targetYear = data.year || new Date().getFullYear();

    console.log(`Manual leave quota reset initiated by ${context.auth.uid} for year ${targetYear}`);

    try {
        const SICK_LEAVE_YEARLY = 12;
        const PAID_LEAVE_YEARLY = 20;

        const usersSnapshot = await db.collection('users')
            .where('is_active', '==', true)
            .get();

        const batch = db.batch();
        let processedCount = 0;

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;

            // Check if leave balance already exists for this year
            const existingBalance = await db.collection('leave_balances')
                .where('user_id', '==', userId)
                .where('year', '==', targetYear)
                .limit(1)
                .get();

            let leaveBalanceRef;

            if (!existingBalance.empty) {
                // Update existing
                leaveBalanceRef = existingBalance.docs[0].ref;
            } else {
                // Create new
                leaveBalanceRef = db.collection('leave_balances').doc();
            }

            const newLeaveBalance = {
                user_id: userId,
                year: targetYear,
                sick_leave: {
                    total: SICK_LEAVE_YEARLY,
                    used: 0,
                    remaining: SICK_LEAVE_YEARLY
                },
                paid_leave: {
                    total: PAID_LEAVE_YEARLY,
                    used: 0,
                    remaining: PAID_LEAVE_YEARLY
                },
                monthly_usage: {},
                updated_at: admin.firestore.FieldValue.serverTimestamp()
            };

            batch.set(leaveBalanceRef, newLeaveBalance, { merge: false });
            processedCount++;

            if (processedCount % 500 === 0) {
                await batch.commit();
            }
        }

        if (processedCount % 500 !== 0) {
            await batch.commit();
        }

        // Log the manual reset
        await db.collection('system_logs').add({
            event: 'manual_leave_quota_reset',
            year: targetYear,
            users_processed: processedCount,
            initiated_by: context.auth.uid,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        return {
            success: true,
            message: `Successfully reset leave quotas for ${processedCount} users for year ${targetYear}`
        };

    } catch (error) {
        console.error('Error in manual reset:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});
