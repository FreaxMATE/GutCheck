import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform detection utilities
class PlatformUtils {
  /// Returns true if running in a web browser
  static bool get isWeb => kIsWeb;

  /// Returns true if running on iOS or Android
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Returns true if running on desktop (Linux, Windows, or macOS)
  static bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  /// Get platform name for debugging
  static String get platformName {
    if (isWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
