#!/bin/bash

# Script to insert sample admin and manager data
# Usage: ./insert_sample_data.sh

echo "🔧 Inserting sample data for WorkLinker..."
echo ""
echo "This will create:"
echo "  - Admin user: +918209556233"
echo "  - Manager user: +918209556222"
echo ""

# Check if Flutter/Dart is available
if ! command -v dart &> /dev/null && ! command -v flutter &> /dev/null; then
    echo "❌ Dart/Flutter is not installed."
    echo "💡 Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Run the Dart script
if command -v flutter &> /dev/null; then
    echo "📱 Running with Flutter..."
    flutter run -d none -t insert_sample_data.dart
else
    echo "📱 Running with Dart..."
    dart run insert_sample_data.dart
fi

echo ""
echo "✅ Done! You can now login with:"
echo "   Admin: +918209556233 (OTP: 123456)"
echo "   Manager: +918209556222 (OTP: 123456)"
