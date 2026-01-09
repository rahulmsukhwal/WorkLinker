class AntiBypassFilter {
  // Regex patterns for blocking
  static final RegExp phoneRegex = RegExp(r'\d{10,}');
  static final RegExp emailRegex = RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );
  static final RegExp urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  /// Checks if text contains forbidden patterns
  static bool containsForbiddenContent(String text) {
    return phoneRegex.hasMatch(text) ||
        emailRegex.hasMatch(text) ||
        urlRegex.hasMatch(text);
  }

  /// Sanitizes text by removing/replacing forbidden patterns
  static String sanitizeText(String text) {
    String sanitized = text;

    // Replace phone numbers
    sanitized = sanitized.replaceAll(phoneRegex, '[Phone number blocked]');

    // Replace emails
    sanitized = sanitized.replaceAll(emailRegex, '[Email blocked]');

    // Replace URLs
    sanitized = sanitized.replaceAll(urlRegex, '[Link blocked]');

    return sanitized;
  }

  /// Validates message before sending
  static String? validateMessage(String text) {
    if (containsForbiddenContent(text)) {
      return 'Message contains blocked content (phone numbers, emails, or links). Please remove them.';
    }
    return null;
  }
}
