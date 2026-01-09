#!/bin/bash

# Script to make a phone number admin in Firestore
# Usage: ./make_admin.sh [phone_number]
# Example: ./make_admin.sh +918209556233

# Default phone number
PHONE_NUMBER="${1:-+918209556233}"

echo "🔧 Making admin for phone number: $PHONE_NUMBER"
echo ""

# Project ID
PROJECT_ID="worklinker-f2231"

echo "📝 To make this phone number admin, follow these steps:"
echo ""
echo "Method 1: Using Firebase Console (Easiest)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo "2. Click on 'users' collection"
echo "3. Find the document where 'phone' field equals: $PHONE_NUMBER"
echo "4. Click on that document"
echo "5. Click 'Edit document' (pencil icon)"
echo "6. Change 'globalRole' field value to: admin"
echo "7. Click 'Update'"
echo ""
echo "Method 2: Using Dart Script (Requires user to be logged in first)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Make sure the user with phone $PHONE_NUMBER has logged in at least once"
echo "2. Run: flutter run -t make_admin.dart --dart-define=PHONE=$PHONE_NUMBER"
echo "   OR manually edit make_admin.dart and run: dart run make_admin.dart $PHONE_NUMBER"
echo ""
echo "✅ After updating, the user will have admin privileges on next login."
echo ""
