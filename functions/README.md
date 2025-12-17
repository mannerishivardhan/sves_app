# Cloud Functions for Leave Management

## Overview

This directory contains Firebase Cloud Functions for the SVES Leave Management system.

## Functions

### 1. `resetYearlyLeaveQuotas` (Scheduled)

**Purpose**: Automatically reset leave balances for all active employees on January 1st each year.

**Schedule**: Runs at 00:00 UTC on January 1st
- Cron expression: `0 0 1 1 *`

**What it does**:
- Fetches all active users from Firestore
- Creates new leave balance records for the current year
- Resets sick leave to 12 days
- Resets paid leave to 20 days
- Clears monthly usage tracking
- Logs the reset operation

**Batching**: Processes users in batches of 500 for efficiency

### 2. `manualResetLeaveQuotas` (Callable)

**Purpose**: Allow Super Admin to manually trigger leave quota reset for testing or emergency situations.

**Authentication**: Required
**Authorization**: Super Admin only

**Parameters**:
```javascript
{
  year: 2025  // Optional, defaults to current year
}
```

**Usage from Flutter**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('manualResetLeaveQuotas');
final result = await callable.call({
  'year': 2025,
});
```

## Setup

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Deploy to Firebase

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:resetYearlyLeaveQuotas
```

### 3. Testing Locally

```bash
# Start Firebase emulator
cd functions
npm run serve

# In another terminal, trigger the function manually
firebase functions:shell
> resetYearlyLeaveQuotas()
```

## Configuration

### Update Leave Quotas

If you need to change the yearly leave quotas, update these constants in `index.js`:

```javascript
const SICK_LEAVE_YEARLY = 12;
const PAID_LEAVE_YEARLY = 20;
```

### Change Schedule

To modify when the reset occurs, change the cron expression:

```javascript
.schedule('0 0 1 1 *')  // Current: Jan 1 at 00:00
.schedule('0 0 1 * *')  // Example: 1st of every month at 00:00
```

## Monitoring

### View Logs

```bash
# Real-time logs
firebase functions:log

# Or view in Firebase Console
# Functions > Logs
```

### System Logs Collection

All reset operations are logged to Firestore collection `system_logs`:

```javascript
{
  event: 'yearly_leave_quota_reset',
  year: 2025,
  users_processed: 156,
  timestamp: <firestore_timestamp>
}
```

## Error Handling

- Skips inactive users automatically
- Logs errors to `system_logs` collection
- Uses batched writes to avoid Firestore limits
- Implements proper error handling and rollback

## Cost Considerations

- **Scheduled function**: Runs once per year (minimal cost)
- **Firestore writes**: ~1-2 writes per user (156 users = ~312 writes)
- **Estimated cost**: < $0.01 per year for typical usage

## Security

- Manual trigger requires authentication
- Only Super Admin can execute manual reset
- Verifies user role before proceeding
- Logs all operations for audit trail
