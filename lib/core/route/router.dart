import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/bottom_nav/bottom_nav.dart';
import 'package:dealer/features/client/bottom_nav_client/presentation/pages/bottom_nav.dart';
import 'package:dealer/features/live_auction/presentation/pages/vehicle_detail_page.dart';
import 'package:dealer/features/login/presentation/pages/login_page.dart';
import 'package:dealer/features/login/presentation/pages/otp_page.dart';
import 'package:dealer/features/onboarding/presentation/pages/onb_page.dart';
import 'package:dealer/features/signup/presentation/pages/signup_page.dart';
import 'package:dealer/features/splash/splash.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage),
    AutoRoute(page: OtpPage),
    AutoRoute(page: BottomNavPage),
    AutoRoute(page: DealerOnboardingPage),
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: ClientBottomNavPage),
    AutoRoute(page: VehicleDetailPage),
    AutoRoute(page: SignupPage),
  ],
)
class $AppRouter {}
