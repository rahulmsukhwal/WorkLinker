# WorkLinker
Controlled Client-Developer Collaboration Platform

## Overview

WorkLinker is a Flutter-based mobile application that provides a controlled environment for collaboration between clients, developers, managers, and administrators. All communication stays within the app with strict anti-bypass measures to prevent direct contact information sharing.

## Features

- **Phone OTP Authentication**: Secure login using Firebase Auth with phone number verification
- **Role-Based Access Control**: Global roles (admin, manager, developer, client) and project-specific roles
- **Project Management**: Create projects, assign members, and manage teams
- **Group Chat**: Real-time messaging with text, voice notes, and file attachments
- **Anti-Bypass System**: Automatic filtering of phone numbers, emails, and external links
- **Identity Masking**: Users are displayed with aliases (e.g., Dev-XX, Manager-XX)
- **Admin Panel**: Built-in admin interface for user and project management

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── services/         # Business logic services
│   ├── providers/        # State management providers
│   ├── router/           # Navigation routing
│   └── utils/            # Utility functions
├── features/
│   ├── auth/             # Authentication screens
│   ├── dashboard/        # Dashboard screen
│   ├── project/          # Project management screens
│   ├── chat/             # Chat functionality
│   └── admin/            # Admin panel
└── main.dart             # App entry point
```

## Setup Instructions

### 1. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Phone provider
3. Create Firestore database
4. Enable Firebase Storage
5. Run `flutterfire configure` to generate `firebase_options.dart`
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Create Admin User

Before using the app, manually create an admin user in Firestore:

```javascript
// In Firestore console, create document: users/{uid}
{
  phone: "+91xxxxxxxxxx",
  globalRole: "admin",
  status: "active",
  createdAt: Timestamp.now()
}
```

### 4. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

## Firestore Collections

### users/
- `phone`: User's phone number
- `globalRole`: admin | manager | developer | client
- `status`: active | inactive
- `createdAt`: Timestamp

### projects/
- `title`: Project title
- `description`: Optional description
- `createdBy`: User ID of creator
- `createdAt`: Timestamp

### projectMembers/
- `projectId`: Reference to project
- `userId`: Reference to user
- `projectRole`: manager | developer | client
- `addedBy`: User ID who added this member
- `addedAt`: Timestamp

### groups/
- `memberIds`: Array of user IDs

### messages/
- `projectId`: Reference to project
- `senderId`: User ID of sender
- `type`: text | voice | file
- `content`: Message content
- `fileUrl`: URL for voice/file messages
- `timestamp`: Timestamp
- `readBy`: Array of user IDs who read the message

## Permissions

### Admin
- Create projects
- Add/remove managers, developers, clients
- Remove anyone from groups
- Close/delete projects
- View all projects
- Access admin panel

### Manager
- Create projects
- Add/remove developers
- Cannot remove admin, client, or other managers
- Cannot close/delete projects

### Developer
- Chat in assigned projects
- Leave projects
- No management rights

### Client
- Chat in assigned projects
- View assigned developers & manager
- No adding/removing rights
- No settings access

## Anti-Bypass Features

The app automatically:
- Blocks phone numbers (10+ digits)
- Blocks email addresses
- Blocks external URLs
- Sanitizes messages before sending
- Shows validation errors for blocked content

## Identity Masking

All users are displayed with aliases:
- Admin → Admin-XXXX
- Manager → Manager-XXXX
- Developer → Dev-XXXX
- Client → Client-XXXX

Only admins can see real identities in the admin panel.

## Building the App

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Development

### Running the app
```bash
flutter run
```

### Running tests
```bash
flutter test
```

## Security Notes

- All Firestore operations are protected by security rules
- Phone numbers are validated and stored securely
- Messages are sanitized before storage
- Role-based permissions are enforced at both UI and database levels

## License

This project is proprietary software.
