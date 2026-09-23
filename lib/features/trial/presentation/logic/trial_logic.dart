// lib/features/trial/presentation/logic/trial_logic.dart
//
// Tracks the free-trial window entirely on-device — there's no backend
// endpoint for this yet, so "one trial per device" really means "one
// trial per app install": SharedPreferences persists across app
// restarts and even most updates, but a full uninstall/reinstall (or
// clearing app storage) resets it. If you need this to survive a
// reinstall, the real fix is a server-side check — send a stable device
// id (device_info_plus) to the backend when starting a trial and have
// it refuse a second one, the same way auth/register already tracks
// accounts. This is the client-side half either way (it also gates the
// UI instantly, without waiting on a network round trip).
//
// Mirrors DashBoardLogic's shape (ChangeNotifier + ChangeNotifierProvider)
// since this is local device state, not a network call — there's no
// loading/data/error to model, so freezed/notifier+usecase would be
// unnecessary ceremony here.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final trialLogic = ChangeNotifierProvider<TrialLogic>((ref) => TrialLogic());

class TrialLogic extends ChangeNotifier {
  TrialLogic() {
    _load();
  }

  static const Duration trialDuration = Duration(hours: 48);
  static const String _kStartedAtKey = 'trial_started_at_millis';
  static const String _kEverUsedKey = 'trial_ever_used';

  DateTime? _startedAt;
  bool _everUsed = false;
  bool _loaded = false;
  Timer? _tickTimer;

  bool get isLoaded => _loaded;

  /// This device has started a trial before — whether it's still
  /// counting down or long expired. Once true, it never goes back to
  /// false: that's what "no second trial on this device" means.
  bool get everUsedTrial => _everUsed;

  /// True the whole time a trial is running OR after it's expired —
  /// i.e. "this is a guest/trial session at all", regardless of the
  /// clock. Bidding is gated on this, not on isTrialActive, because a
  /// trial user shouldn't be able to bid even during the 48 hours —
  /// only a registered account can.
  bool get isTrialSession => _startedAt != null;

  bool get isTrialActive =>
      _startedAt != null &&
      DateTime.now().isBefore(_startedAt!.add(trialDuration));

  bool get isTrialExpired => isTrialSession && !isTrialActive;

  Duration get remaining {
    if (_startedAt == null) return Duration.zero;
    final left = _startedAt!.add(trialDuration).difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final startedMillis = prefs.getInt(_kStartedAtKey);
    _startedAt = startedMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(startedMillis)
        : null;
    _everUsed = prefs.getBool(_kEverUsedKey) ?? false;
    _loaded = true;
    _startTicking();
    notifyListeners();
  }

  /// Starts the 48-hour trial. Returns false and changes nothing if
  /// this device has already used its one trial — callers should check
  /// [everUsedTrial] first and show the "already used" message instead
  /// of relying on this return value alone, but it's checked again here
  /// too so a stale UI state can't accidentally start a second trial.
  Future<bool> startTrial() async {
    if (_everUsed) return false;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_kStartedAtKey, now.millisecondsSinceEpoch);
    // Locked in the moment the trial starts, not only once the 48 hours
    // pass — otherwise force-closing the app mid-trial and clearing
    // just the "started at" value (or a clock change) could look like
    // a trial that was never used.
    await prefs.setBool(_kEverUsedKey, true);
    _startedAt = now;
    _everUsed = true;
    _startTicking();
    notifyListeners();
    return true;
  }

  /// Call this the moment a REAL account session begins (OTP verified,
  /// registration completed) — a genuine login ends guest/trial mode
  /// even if trial time is still left, since bidding is now allowed
  /// through the real account instead. [everUsedTrial] deliberately
  /// stays true: signing up doesn't refund the trial.
  void endTrialSession() {
    if (_startedAt == null) return;
    _startedAt = null;
    _tickTimer?.cancel();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove(_kStartedAtKey));
    notifyListeners();
  }

  void _startTicking() {
    _tickTimer?.cancel();
    if (_startedAt == null) return;
    // Coarse tick — this only drives a countdown display, not the
    // authoritative expiry check (that's always computed fresh from
    // DateTime.now() in isTrialActive/isTrialExpired above).
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners();
      if (isTrialExpired) _tickTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
