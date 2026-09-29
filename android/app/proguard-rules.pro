# ── ML Kit (existing) ────────────────────────────────────────────────
-dontwarn com.google.mlkit.vision.text.**
-keep class com.google.mlkit.vision.text.** { *; }

# ── flutter_secure_storage ───────────────────────────────────────────
# Without these, R8 strips classes the plugin needs to talk to the
# Android Keystore — this is the single most common cause of "works
# in debug, hangs/crashes silently in release on a real device" for
# apps using this plugin, since the emulator's keystore behavior and
# fresh installs don't always hit the same code path.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }

# ── geolocator ────────────────────────────────────────────────────────
-keep class com.baseflow.geolocator.** { *; }

# ── Google Play Services location (used by geolocator under the hood) ─
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# ── General safety net for AndroidX/Kotlin reflection-based crashes ──
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod