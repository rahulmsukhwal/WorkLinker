# How to Create Admin User in Firebase Firestore

## Method 1: Create Admin Before First Login (Recommended)

### Step 1: Get User UID from Firebase Auth
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **worklinker-f2231**
3. Click on **Authentication** in the left menu
4. Click on **Users** tab
5. If you see any users, note their **UID** (copy it)
6. If no users exist yet, you'll need to create one after first login (see Method 2)

### Step 2: Create Admin User in Firestore
1. In Firebase Console, click on **Firestore Database** in the left menu
2. Click on **Data** tab
3. Click on **Start collection** (if no collections exist) or find the **users** collection
4. If **users** collection doesn't exist:
   - Click **Start collection**
   - Collection ID: `users`
   - Click **Next**
5. Document ID: **Paste the UID from Step 1** (or use Auto-ID for now)
6. Add the following fields:

| Field | Type | Value |
|-------|------|-------|
| `phone` | string | `+918209556233` (your phone number) |
| `globalRole` | string | `admin` |
| `status` | string | `active` |
| `createdAt` | timestamp | Click "Set" and select current date/time |

7. Click **Save**

## Method 2: Update Existing User to Admin

If you've already logged in and a user document was created:

1. Go to **Firestore Database** → **Data** tab
2. Find the **users** collection
3. Click on the user document (the one with your phone number)
4. Click on the **globalRole** field
5. Change the value from `client` to `admin`
6. Click **Update**

## Method 3: Create Admin Using Document ID = Firebase Auth UID

### Step 1: Login to App First
1. Open the app
2. Enter your phone number: `+918209556233`
3. Enter OTP: `123456`
4. Login successfully

### Step 2: Get Your UID
1. Go to Firebase Console → **Authentication** → **Users**
2. Find your user (by phone number or email if shown)
3. Copy the **UID** (it's a long string like: `abc123xyz456...`)

### Step 3: Create/Update User Document
1. Go to **Firestore Database** → **Data** tab
2. Find or create **users** collection
3. Click **Add document**
4. Document ID: **Paste your UID** (IMPORTANT: Use the exact UID from Authentication)
5. Add fields:

```json
{
  "phone": "+918209556233",
  "globalRole": "admin",
  "status": "active",
  "createdAt": [Current Timestamp]
}
```

6. Click **Save**

## Verification

After creating the admin user:
1. Logout from the app (if logged in)
2. Login again with the same phone number
3. You should see the **Admin Panel** icon in the dashboard
4. You should be able to access admin features

## Quick Reference - User Document Structure

```json
{
  "phone": "+918209556233",
  "globalRole": "admin",        // Options: "admin", "manager", "developer", "client"
  "status": "active",            // Options: "active", "inactive"
  "createdAt": [Timestamp]       // Current date/time
}
```

## Troubleshooting

- **Can't see admin panel?** 
  - Check that `globalRole` is exactly `admin` (lowercase, no quotes in the field value)
  - Make sure the document ID matches your Firebase Auth UID
  - Logout and login again

- **Permission denied?**
  - Make sure you've deployed the updated Firestore rules
  - Check that the user document exists in Firestore

- **Document ID doesn't match?**
  - The document ID in Firestore `users` collection must match the UID from Firebase Authentication
  - Check Authentication → Users to get the correct UID
