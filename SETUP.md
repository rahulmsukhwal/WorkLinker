# WorkLinker Setup Guide

## Prerequisites

1. Flutter SDK (3.0.0 or higher)
2. Android Studio / Xcode (for mobile development)
3. Firebase account
4. Firebase CLI (optional, for deploying rules)

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Firebase Setup

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Follow the setup wizard

### 2.2 Configure Firebase for Flutter

Run the FlutterFire CLI to configure Firebase:

```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Detect your Firebase projects
- Generate `firebase_options.dart` with your project configuration
- Configure Android and iOS apps

### 2.3 Enable Firebase Services

#### Authentication
1. Go to Firebase Console > Authentication
2. Click "Get started"
3. Enable "Phone" sign-in method
4. Configure reCAPTCHA settings

#### Firestore Database
1. Go to Firebase Console > Firestore Database
2. Click "Create database"
3. Start in **test mode** (we'll deploy security rules later)
4. Choose a location

#### Storage
1. Go to Firebase Console > Storage
2. Click "Get started"
3. Start in **test mode**
4. Use the same location as Firestore

#### Cloud Messaging (FCM)
1. Go to Firebase Console > Cloud Messaging
2. No additional setup needed for basic functionality

### 2.4 Deploy Firestore Security Rules

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firestore.rules` to Firebase Console > Firestore > Rules

## Step 3: Create Admin User

Before using the app, create an admin user in Firestore:

1. Go to Firebase Console > Firestore Database
2. Create a new collection: `users`
3. Create a document with ID = your Firebase Auth UID (you'll get this after first login)
4. Add the following fields:

```json
{
  "phone": "+91xxxxxxxxxx",
  "globalRole": "admin",
  "status": "active",
  "createdAt": [Use Timestamp - current time]
}
```

**Alternative:** Login once with your phone, note the UID from Firebase Auth, then update the user document in Firestore to set `globalRole: "admin"`.

## Step 4: Android Configuration

### 4.1 Update AndroidManifest.xml

The `AndroidManifest.xml` is already configured, but verify:
- Internet permission
- Phone state permission (if needed)
- Storage permissions

### 4.2 Add google-services.json

1. In Firebase Console, go to Project Settings
2. Under "Your apps", select Android app
3. Download `google-services.json`
4. Place it in `android/app/`

## Step 5: iOS Configuration

### 5.1 Update Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record voice messages</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to send images</string>
```

### 5.2 Add GoogleService-Info.plist

1. In Firebase Console, go to Project Settings
2. Under "Your apps", select iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

## Step 6: Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

## Step 7: Testing

### Test Admin Login
1. Login with the admin phone number
2. You should see the admin panel icon in the dashboard
3. Create a test project

### Test Project Creation
1. As admin or manager, create a new project
2. Enter client phone number
3. Verify project appears in dashboard
4. Verify group chat is created automatically

### Test Chat
1. Open a project
2. Click "Open Chat"
3. Send a test message
4. Verify anti-bypass filter blocks phone numbers/emails

## Troubleshooting

### Firebase not initialized
- Ensure `firebase_options.dart` exists
- Run `flutterfire configure` again

### OTP not received
- Check Firebase Console > Authentication > Phone
- Verify phone number format (include country code)
- Check reCAPTCHA configuration

### Permission errors
- Verify Firestore security rules are deployed
- Check Storage rules in Firebase Console

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Delete `ios/Pods` and `ios/Podfile.lock`, then run `pod install` (iOS only)

## Next Steps

1. Customize app icon and splash screen
2. Configure push notifications (FCM)
3. Set up Cloud Functions for advanced features
4. Add analytics
5. Configure app signing for release builds

## Support

For issues, check:
- Firebase Console logs
- Flutter logs: `flutter logs`
- Firestore security rules errors in Firebase Console

