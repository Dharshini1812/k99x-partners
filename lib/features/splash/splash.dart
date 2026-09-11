import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@AutoRoute()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────
  // Animation
  // ─────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  // Continuous rotation controller for orange arc
  late final AnimationController _rotationCtrl;

  // ─────────────────────────────────────────────
  // Internet checking
  // ─────────────────────────────────────────────
  Timer? _internetCheckTimer;

  bool isOffline = false;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    // ───────────────────────────────────────────
    // Main splash animation
    // ───────────────────────────────────────────
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.elasticOut,
      ),
    );

    _ctrl.forward();

    // ───────────────────────────────────────────
    // Rotating orange arc
    // ───────────────────────────────────────────
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // ───────────────────────────────────────────
    // Check internet
    // ───────────────────────────────────────────
    _checkInternet();
  }

  // ═════════════════════════════════════════════
  // INTERNET CHECK
  // ═════════════════════════════════════════════

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInternet() async {
    final connected = await _hasInternet();

    if (!mounted) return;

    if (connected) {
      setState(() {
        isOffline = false;
      });

      _startNavigation();
    } else {
      setState(() {
        isOffline = true;
      });

      _startInternetRetry();
    }
  }

  // Check every 2 seconds while offline
  void _startInternetRetry() {
    _internetCheckTimer?.cancel();

    _internetCheckTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        final connected = await _hasInternet();

        if (!mounted) return;

        if (connected) {
          _internetCheckTimer?.cancel();

          setState(() {
            isOffline = false;
          });

          _startNavigation();
        }
      },
    );
  }

  // ═════════════════════════════════════════════
  // NAVIGATION
  // ═════════════════════════════════════════════

  Future<void> _startNavigation() async {
    if (_navigationStarted) return;

    _navigationStarted = true;

    // Keep splash visible for 2.6 seconds
    await Future.delayed(
      const Duration(milliseconds: 2600),
    );

    if (!mounted) return;

    // Check again before navigation
    final connected = await _hasInternet();

    if (!connected) {
      _navigationStarted = false;

      setState(() {
        isOffline = true;
      });

      _startInternetRetry();

      return;
    }

    // ───────────────────────────────────────────
    // Get stored user
    // ───────────────────────────────────────────
    final storage = SecureStorageService();
    final user = await storage.getUser();

    if (!mounted) return;

    // No user
    if (user == null) {
      ref.read(routeService).pushAndRemoveUntil(
            const DealerOnboardingRoute(),
            context,
          );

      return;
    }

    // CLIENT
    if (user.userType == 'CLIENT') {
      ref.read(routeService).pushAndRemoveUntil(
            const ClientBottomNavRoute(),
            context,
          );

      return;
    }

    // DEALER
    if (user.userType == 'DEALER') {
      ref.read(routeService).pushAndRemoveUntil(
            const BottomNavRoute(),
            context,
          );

      return;
    }
  }

  // ═════════════════════════════════════════════
  // DISPOSE
  // ═════════════════════════════════════════════

  @override
  void dispose() {
    _internetCheckTimer?.cancel();
    _ctrl.dispose();
    _rotationCtrl.dispose();

    super.dispose();
  }

  // ═════════════════════════════════════════════
  // UI
  // ═════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // ───────────────────────────────────────────
    // NO INTERNET SCREEN
    // ───────────────────────────────────────────
    if (isOffline) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/no_internet.jpg',
                  width: 300,
                  fit: BoxFit.contain,
                ),

                // Optional manual retry button
                ElevatedButton(
                  onPressed: () {
                    _checkInternet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2FE0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ───────────────────────────────────────────
    // NORMAL SPLASH SCREEN
    // ───────────────────────────────────────────
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─────────────────────────────────────
          // Decorative top-right shape
          // ─────────────────────────────────────
          Positioned(
            top: -40,
            right: -60,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEDEFF7),
                      const Color(0xFFEDEFF7).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────
          // Center content
          // ─────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─────────────────────────
                    // Logo with rotating arc
                    // ─────────────────────────
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Faint full ring
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFEDEFF4),
                                width: 2,
                              ),
                            ),
                          ),

                          // Orange rotating arc
                          RotationTransition(
                            turns: _rotationCtrl,
                            child: CustomPaint(
                              size: const Size(140, 140),
                              painter: _ArcPainter(
                                color: const Color(0xFFF39C12),
                                strokeWidth: 2.4,
                                sweepFraction: 0.72,
                              ),
                            ),
                          ),

                          // Logo
                          Container(
                            width: 108,
                            height: 108,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E2FE0),
                            ),
                            padding: const EdgeInsets.all(26),
                            child: Image.asset(
                              'images/logo/small-logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.directions_car_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─────────────────────────
                    // App name
                    // ─────────────────────────
                    const Text(
                      'K99X',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF11142A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ─────────────────────────
                    // Subtitle
                    // ─────────────────────────
                    const Text(
                      'Dealer Stocks',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B4EF5),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────
                    // Tagline
                    // ─────────────────────────
                    const Text(
                      'UPLOAD  ·  MANAGE  ·  SELL STOCKS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: Color(0xFFB0B4C2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// PARTIAL ARC PAINTER
// ═══════════════════════════════════════════════

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepFraction;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14 / 2 - 0.6;

    final sweepAngle = 2 * 3.14159 * sweepFraction;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.sweepFraction != sweepFraction ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
