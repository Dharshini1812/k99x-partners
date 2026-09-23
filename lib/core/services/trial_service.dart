import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TrialService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static const String _keyTrialStartTime = 'trial_start_time';
  static const String _keyTrialConsumed = 'trial_consumed_device_';
  static const String _keyIsTrialUser = 'is_trial_active_session';
  static const Duration trialDuration = Duration(hours: 48);

  /// Retrieves a unique hardware fingerprint for the device
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id; // Hardware build ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown_device';
      }
    } catch (_) {}
    return 'fallback_device_uuid';
  }

  /// Checks whether this hardware device has ever claimed the trial
  static Future<bool> hasDeviceConsumedTrial() async {
    final deviceId = await getDeviceId();
    final consumed = await _storage.read(key: '$_keyTrialConsumed$deviceId');
    return consumed == 'true';
  }

  /// Starts the 48-hour trial; returns false if device was already consumed
  static Future<bool> startTrial() async {
    final alreadyUsed = await hasDeviceConsumedTrial();
    if (alreadyUsed) return false;

    final deviceId = await getDeviceId();
    final now = DateTime.now().toIso8601String();

    await _storage.write(key: '$_keyTrialConsumed$deviceId', value: 'true');
    await _storage.write(key: _keyTrialStartTime, value: now);
    await _storage.write(key: _keyIsTrialUser, value: 'true');

    return true;
  }

  /// Verifies if the current user session is a trial session
  static Future<bool> isTrialUser() async {
    final value = await _storage.read(key: _keyIsTrialUser);
    return value == 'true';
  }

  /// Checks if the trial is still within the 48-hour limit
  static Future<bool> isTrialActive() async {
    final isTrial = await isTrialUser();
    if (!isTrial) return false;

    final startStr = await _storage.read(key: _keyTrialStartTime);
    if (startStr == null) return false;

    final startTime = DateTime.tryParse(startStr);
    if (startTime == null) return false;

    final diff = DateTime.now().difference(startTime);
    return diff < trialDuration;
  }

  /// Returns remaining time in the 48-hour window
  static Future<Duration> getRemainingTime() async {
    final startStr = await _storage.read(key: _keyTrialStartTime);
    if (startStr == null) return Duration.zero;

    final startTime = DateTime.tryParse(startStr);
    if (startTime == null) return Duration.zero;

    final elapsed = DateTime.now().difference(startTime);
    final remaining = trialDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Clears trial session flags on full signup/logout without wiping the hardware consumption lock
  static Future<void> endTrialSession() async {
    await _storage.delete(key: _keyIsTrialUser);
    await _storage.delete(key: _keyTrialStartTime);
  }
}
