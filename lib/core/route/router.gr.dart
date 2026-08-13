// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../../features/bottom_nav/bottom_nav.dart' as _i3;
import '../../features/login/presentation/pages/login_page.dart' as _i1;
import '../../features/login/presentation/pages/otp_page.dart' as _i2;
import '../../features/onboarding/presentation/pages/onb_page.dart' as _i4;
import '../../features/splash/splash.dart' as _i5;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    LoginRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPage(),
      );
    },
    OtpRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.OtpPage(),
      );
    },
    BottomNavRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.BottomNavPage(),
      );
    },
    DealerOnboardingRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.DealerOnboardingPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.SplashPage(),
      );
    },
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(
          LoginRoute.name,
          path: '/login-page',
        ),
        _i6.RouteConfig(
          OtpRoute.name,
          path: '/otp-page',
        ),
        _i6.RouteConfig(
          BottomNavRoute.name,
          path: '/bottom-nav-page',
        ),
        _i6.RouteConfig(
          DealerOnboardingRoute.name,
          path: '/dealer-onboarding-page',
        ),
        _i6.RouteConfig(
          SplashRoute.name,
          path: '/',
        ),
      ];
}

/// generated route for
/// [_i1.LoginPage]
class LoginRoute extends _i6.PageRouteInfo<void> {
  const LoginRoute()
      : super(
          LoginRoute.name,
          path: '/login-page',
        );

  static const String name = 'LoginRoute';
}

/// generated route for
/// [_i2.OtpPage]
class OtpRoute extends _i6.PageRouteInfo<void> {
  const OtpRoute()
      : super(
          OtpRoute.name,
          path: '/otp-page',
        );

  static const String name = 'OtpRoute';
}

/// generated route for
/// [_i3.BottomNavPage]
class BottomNavRoute extends _i6.PageRouteInfo<void> {
  const BottomNavRoute()
      : super(
          BottomNavRoute.name,
          path: '/bottom-nav-page',
        );

  static const String name = 'BottomNavRoute';
}

/// generated route for
/// [_i4.DealerOnboardingPage]
class DealerOnboardingRoute extends _i6.PageRouteInfo<void> {
  const DealerOnboardingRoute()
      : super(
          DealerOnboardingRoute.name,
          path: '/dealer-onboarding-page',
        );

  static const String name = 'DealerOnboardingRoute';
}

/// generated route for
/// [_i5.SplashPage]
class SplashRoute extends _i6.PageRouteInfo<void> {
  const SplashRoute()
      : super(
          SplashRoute.name,
          path: '/',
        );

  static const String name = 'SplashRoute';
}
