import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/bottom_nav/bottom_nav.dart';
import 'package:dealer/features/login/presentation/pages/login_page.dart';
import 'package:dealer/features/login/presentation/pages/otp_page.dart';
import 'package:dealer/features/splash/splash.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage),
    AutoRoute(page: OtpPage),
    AutoRoute(page: BottomNavPage),
    AutoRoute(page: SplashPage, initial: true),
  ],
)
class $AppRouter {}
