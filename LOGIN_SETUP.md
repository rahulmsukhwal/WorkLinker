# Login Setup Guide

## Quick Start

### 1. Insert Sample Data

Run the script to create admin and manager users:

```bash
./insert_sample_data.sh
```

Or manually:

```bash
dart run insert_sample_data.dart
```

This creates:
- **Admin**: +918209556233
- **Manager**: +918209556222

### 2. Update Firebase Rules

Copy the rules from `firestore.rules` to Firebase Console:
1. Go to: https://console.firebase.google.com/project/worklinker-f2231/firestore/rules
2. Replace all content with rules from `firestore.rules`
3. Click "Publish"

### 3. Login

1. Open the app
2. Enter phone number (10 digits, e.g., `8209556233`)
3. The app will auto-add `+91` prefix
4. Enter OTP: `123456` (hardcoded for testing)
5. You're logged in!

## Phone Number Format

- **Input**: Enter 10 digits (e.g., `8209556233`)
- **Auto-format**: App automatically adds `+91` prefix
- **Accepted formats**:
  - `8209556233` → `+918209556233` ✅
  - `08209556233` → `+918209556233` ✅
  - `+918209556233` → `+918209556233` ✅
  - `918209556233` → `+918209556233` ✅

## Sample Users

| Phone Number | Role | OTP |
|-------------|------|-----|
| +918209556233 | Admin | 123456 |
| +918209556222 | Manager | 123456 |

## Troubleshooting

### Login Not Working?

1. **Check Firebase Rules**: Make sure rules are published in Firebase Console
2. **Check Sample Data**: Run `insert_sample_data.sh` to ensure users exist
3. **Check Phone Format**: Make sure phone number is correct (10 digits)
4. **Check OTP**: Use `123456` for testing

### "User not found" Error?

- Run `insert_sample_data.sh` to create sample users
- Make sure phone number matches exactly (with +91 prefix)

### "Permission Denied" Error?

- Update Firebase rules from `firestore.rules`
- Make sure rules allow:
  - Unauthenticated list queries on `users` collection
  - User creation during login

## Firebase Warnings (Safe to Ignore)

These warnings are harmless and don't affect functionality:

- `DynamiteModule`: Google Play Services module warning
- `ProviderInstaller`: Security provider warning
- `App Check token`: App Check not configured (optional)

These are informational only and don't prevent login or app functionality.
