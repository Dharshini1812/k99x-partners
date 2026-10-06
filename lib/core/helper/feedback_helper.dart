// lib/core/helper/feedback_helper.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Haptic + sound feedback that still fires even when the device's
/// silent/mute switch is on.
///
/// HapticFeedback already ignores the ringer/mute state on both
/// platforms — it drives the vibration motor / iOS Taptic Engine
/// directly, which is separate from media/ringer volume. A plain sound
/// effect does NOT behave the same way: on iOS, audio is silenced by
/// the physical mute switch unless the active AVAudioSession category
/// is explicitly `.playback` — that's the one category Apple defines
/// to ignore the mute switch. The AudioContext below sets that up once,
/// so every call to success() plays through it.
class FeedbackHelper {
  FeedbackHelper._();

  static final AudioPlayer _player = AudioPlayer()
    ..setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ),
    );

  /// Light feedback for a low-stakes interaction — switching tabs.
  /// Haptic only; a click sound on every single tab switch would get
  /// old within about a minute of real use.
  static void tap() {
    HapticFeedback.selectionClick();
  }

  /// Feedback for a genuinely consequential, successful action — a bid
  /// (or autobid) actually went through. A firmer haptic plus a short
  /// confirmation sound, both of which fire regardless of the silent
  /// switch.
  static Future<void> success() async {
    HapticFeedback.mediumImpact();
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Sound is a nice-to-have on top of the haptic — never let a
      // playback failure (missing asset, audio focus contention, a
      // device with no speaker, etc.) interrupt the bid flow itself.
    }
  }
}
