import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@AutoRoute()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () async {
      final isLoggedIn = await SecureStorageService().isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        ref
            .read(routeService)
            .pushAndRemoveUntil(const BottomNavRoute(), context);
      } else {
        ref.read(routeService).pushAndRemoveUntil(const LoginRoute(), context);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──────────────────────────────────────────────────

                Icon(Icons.car_rental_sharp)
                // Image.asset(
                //   'images/carsright.png',
                //   width: 180,
                //   fit: BoxFit.contain,
                //   //   errorBuilder: (_, __, ___) => const _FallbackLogo(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
