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
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;

import '../../features/bottom_nav/bottom_nav.dart' as _i3;
import '../../features/client/bottom_nav_client/presentation/pages/bottom_nav.dart'
    as _i6;
import '../../features/live_auction/data/model/live_model.dart' as _i11;
import '../../features/live_auction/presentation/pages/vehicle_detail_page.dart'
    as _i7;
import '../../features/login/presentation/pages/login_page.dart' as _i1;
import '../../features/login/presentation/pages/otp_page.dart' as _i2;
import '../../features/onboarding/presentation/pages/onb_page.dart' as _i4;
import '../../features/signup/presentation/pages/signup_page.dart' as _i8;
import '../../features/splash/splash.dart' as _i5;

class AppRouter extends _i9.RootStackRouter {
  AppRouter([_i10.GlobalKey<_i10.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    LoginRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPage(),
      );
    },
    OtpRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.OtpPage(),
      );
    },
    BottomNavRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.BottomNavPage(),
      );
    },
    DealerOnboardingRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.DealerOnboardingPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.SplashPage(),
      );
    },
    ClientBottomNavRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ClientBottomNavPage(),
      );
    },
    VehicleDetailRoute.name: (routeData) {
      final args = routeData.argsAs<VehicleDetailRouteArgs>();
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i7.VehicleDetailPage(
          key: args.key,
          vehicleId: args.vehicleId,
          vehicle: args.vehicle,
        ),
      );
    },
    SignupRoute.name: (routeData) {
      final args = routeData.argsAs<SignupRouteArgs>(
          orElse: () => const SignupRouteArgs());
      return _i9.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i8.SignupPage(
          key: args.key,
          prefilledMobile: args.prefilledMobile,
        ),
      );
    },
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(
          LoginRoute.name,
          path: '/login-page',
        ),
        _i9.RouteConfig(
          OtpRoute.name,
          path: '/otp-page',
        ),
        _i9.RouteConfig(
          BottomNavRoute.name,
          path: '/bottom-nav-page',
        ),
        _i9.RouteConfig(
          DealerOnboardingRoute.name,
          path: '/dealer-onboarding-page',
        ),
        _i9.RouteConfig(
          SplashRoute.name,
          path: '/',
        ),
        _i9.RouteConfig(
          ClientBottomNavRoute.name,
          path: '/client-bottom-nav-page',
        ),
        _i9.RouteConfig(
          VehicleDetailRoute.name,
          path: '/vehicle-detail-page',
        ),
        _i9.RouteConfig(
          SignupRoute.name,
          path: '/signup-page',
        ),
      ];
}

/// generated route for
/// [_i1.LoginPage]
class LoginRoute extends _i9.PageRouteInfo<void> {
  const LoginRoute()
      : super(
          LoginRoute.name,
          path: '/login-page',
        );

  static const String name = 'LoginRoute';
}

/// generated route for
/// [_i2.OtpPage]
class OtpRoute extends _i9.PageRouteInfo<void> {
  const OtpRoute()
      : super(
          OtpRoute.name,
          path: '/otp-page',
        );

  static const String name = 'OtpRoute';
}

/// generated route for
/// [_i3.BottomNavPage]
class BottomNavRoute extends _i9.PageRouteInfo<void> {
  const BottomNavRoute()
      : super(
          BottomNavRoute.name,
          path: '/bottom-nav-page',
        );

  static const String name = 'BottomNavRoute';
}

/// generated route for
/// [_i4.DealerOnboardingPage]
class DealerOnboardingRoute extends _i9.PageRouteInfo<void> {
  const DealerOnboardingRoute()
      : super(
          DealerOnboardingRoute.name,
          path: '/dealer-onboarding-page',
        );

  static const String name = 'DealerOnboardingRoute';
}

/// generated route for
/// [_i5.SplashPage]
class SplashRoute extends _i9.PageRouteInfo<void> {
  const SplashRoute()
      : super(
          SplashRoute.name,
          path: '/',
        );

  static const String name = 'SplashRoute';
}

/// generated route for
/// [_i6.ClientBottomNavPage]
class ClientBottomNavRoute extends _i9.PageRouteInfo<void> {
  const ClientBottomNavRoute()
      : super(
          ClientBottomNavRoute.name,
          path: '/client-bottom-nav-page',
        );

  static const String name = 'ClientBottomNavRoute';
}

/// generated route for
/// [_i7.VehicleDetailPage]
class VehicleDetailRoute extends _i9.PageRouteInfo<VehicleDetailRouteArgs> {
  VehicleDetailRoute({
    _i10.Key? key,
    required String vehicleId,
    required _i11.LiveAuctionModel vehicle,
  }) : super(
          VehicleDetailRoute.name,
          path: '/vehicle-detail-page',
          args: VehicleDetailRouteArgs(
            key: key,
            vehicleId: vehicleId,
            vehicle: vehicle,
          ),
        );

  static const String name = 'VehicleDetailRoute';
}

class VehicleDetailRouteArgs {
  const VehicleDetailRouteArgs({
    this.key,
    required this.vehicleId,
    required this.vehicle,
  });

  final _i10.Key? key;

  final String vehicleId;

  final _i11.LiveAuctionModel vehicle;

  @override
  String toString() {
    return 'VehicleDetailRouteArgs{key: $key, vehicleId: $vehicleId, vehicle: $vehicle}';
  }
}

/// generated route for
/// [_i8.SignupPage]
class SignupRoute extends _i9.PageRouteInfo<SignupRouteArgs> {
  SignupRoute({
    _i10.Key? key,
    String? prefilledMobile,
  }) : super(
          SignupRoute.name,
          path: '/signup-page',
          args: SignupRouteArgs(
            key: key,
            prefilledMobile: prefilledMobile,
          ),
        );

  static const String name = 'SignupRoute';
}

class SignupRouteArgs {
  const SignupRouteArgs({
    this.key,
    this.prefilledMobile,
  });

  final _i10.Key? key;

  final String? prefilledMobile;

  @override
  String toString() {
    return 'SignupRouteArgs{key: $key, prefilledMobile: $prefilledMobile}';
  }
}
