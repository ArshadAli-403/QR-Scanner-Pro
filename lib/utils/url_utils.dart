// lib/utils/url_utils.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UrlUtils {
  UrlUtils._();

  /// Detect if a string is a valid URL
  static bool isUrl(String text) {
    final uri = Uri.tryParse(text.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'ftp') &&
        uri.host.isNotEmpty;
  }

  /// Detect if it's a phone number
  static bool isPhone(String text) {
    final phoneRegex = RegExp(r'^[+]?[\d\s\-\(\)]{7,15}$');
    return phoneRegex.hasMatch(text.trim());
  }

  /// Detect if it's an email address
  static bool isEmail(String text) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(text.trim());
  }

  /// Detect if it's a Wi-Fi config
  static bool isWifi(String text) {
    return text.trim().startsWith('WIFI:');
  }

  /// Get the type label for a QR text
  static String getQrType(String text) {
    if (isUrl(text)) return 'URL';
    if (isEmail(text)) return 'Email';
    if (isPhone(text)) return 'Phone';
    if (isWifi(text)) return 'Wi-Fi';
    return 'Text';
  }

  /// Get icon for a QR type
  static IconData getQrIcon(String text) {
    if (isUrl(text)) return Icons.link_rounded;
    if (isEmail(text)) return Icons.email_rounded;
    if (isPhone(text)) return Icons.phone_rounded;
    if (isWifi(text)) return Icons.wifi_rounded;
    return Icons.text_fields_rounded;
  }

  /// Launch a URL in external browser
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri.toString());
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Launch URL with proper error handling
  static Future<void> openUrl(
    BuildContext context,
    String url,
  ) async {
    try {
      final uri = Uri.parse(url.trim());
      if (!await launchUrl(uri.toString())) {
        if (context.mounted) {
          _showError(context, 'Could not open URL');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Invalid URL: $url');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
