# Fix Permission Denied Error - Complete Guide

## Problem
Getting `permission-denied` error when verifying OTP and trying to create/read user document.

## Root Cause
1. Firebase rules were too permissive in the `allow create` condition
2. Auth service was trying to read document immediately after creation (timing issue)
3. Rules didn't validate required fields properly

## Solution Applied

### 1. Fixed Firebase Rules
**Before:**
```javascript
allow create: if request.auth != null && 
  (request.auth.uid == userId || 
   (request.resource.data.phone != null && 
    request.resource.data.phone is string));
```

**After:**
```javascript
allow create: if request.auth != null && 
  request.auth.uid == userId &&
  request.resource.data.phone != null &&
  request.resource.data.phone is string &&
  request.resource.data.globalRole != null &&
  request.resource.data.status != null;
```

**Changes:**
- Removed the OR condition that allowed creation without matching UID
- Added validation for all required fields (phone, globalRole, status)
- Ensures user can only create their own document

### 2. Fixed Auth Service
**Before:**
- Created document, then immediately tried to read it
- Could cause timing/permission issues

**After:**
- Creates document with all data
- Returns UserModel directly from the data we just created
- Avoids unnecessary read operation immediately after write

## Steps to Fix

### Step 1: Update Firebase Rules
1. Go to: https://console.firebase.google.com/project/worklinker-f2231/firestore/rules
2. Copy the updated rules from `firestore.rules` file
3. Paste and click "Publish"

### Step 2: Run Sample Data Script (if not done)
```bash
./insert_sample_data.sh
```

This creates:
- Admin: +918209556233
- Manager: +918209556222

### Step 3: Test Login
1. Open app
2. Enter phone: `8209556233` (auto-formats to +918209556233)
3. Enter OTP: `123456`
4. Should login successfully now!

## Why Admin/Manager Not Showing?

The sample data script creates users with **random document IDs** (not Firebase Auth UIDs). When you login:

1. App queries for user by phone number ✅ (finds the admin/manager user)
2. Signs in anonymously (gets new Firebase Auth UID)
3. Creates NEW document with Auth UID
4. **Copies the role** from existing user ✅

So the admin/manager roles **should** be preserved! If they're not showing:

1. **Check if sample data exists:**
   - Go to Firestore Console
   - Check `users` collection
   - Look for documents with phone `+918209556233` or `+918209556222`
   - Check their `globalRole` field

2. **If sample data doesn't exist:**
   ```bash
   ./insert_sample_data.sh
   ```

3. **If sample data exists but role is wrong:**
   - The script should update it
   - Or manually update in Firebase Console:
     - Find user by phone number
     - Change `globalRole` to `admin` or `manager`

## Verification Checklist

- [ ] Firebase rules updated and published
- [ ] Sample data script run successfully
- [ ] Users exist in Firestore with correct phone numbers
- [ ] Users have `globalRole` set to `admin` or `manager`
- [ ] App can login without permission errors
- [ ] User sees correct role after login

## Still Having Issues?

1. **Clear app data** and try again
2. **Check Firebase Console** for any error logs
3. **Verify rules are published** (check Rules tab in Firebase Console)
4. **Check phone number format** (must be `+918209556233` with +91 prefix)

## Updated Files

- ✅ `firestore.rules` - Fixed create permission
- ✅ `lib/core/services/auth_service.dart` - Improved user creation logic

All changes committed to Git!
