import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

abstract class RouteService {
  void push(
    PageRouteInfo<dynamic> route,
    BuildContext context,
  );
  void pop(BuildContext context);
  void pushReplace(PageRouteInfo<dynamic> route, BuildContext context);
  Future<void> pushAndRemoveUntil(
      PageRouteInfo<dynamic> route, BuildContext context);
  void pushNamed();
  void pushNamedReplace(BuildContext context);
  pushWithResult(PageRouteInfo<dynamic> route, BuildContext context);
  void popWithResult(BuildContext context, result);
}

class RouteServiceImpl extends RouteService {
  @override
  void pop(BuildContext context) {
    context.router.pop();
  }

  @override
  void popWithResult(BuildContext context, result) {
    context.router.pop(result);
  }

  @override
  pushWithResult(PageRouteInfo<dynamic> route, BuildContext context) async {
    return await context.router.push(route,
        onFailure: (NavigationFailure failure) {
      if (failure == RouteNotFoundFailure) {
      } else if (failure == RejectedByGuardFailure) {}
    });
  }

  @override
  void push(PageRouteInfo<dynamic> route, BuildContext context) {
    context.router.push(route, onFailure: (NavigationFailure failure) {
      if (failure == RouteNotFoundFailure) {
      } else if (failure == RejectedByGuardFailure) {}
    });
  }

  @override
  Future<void> pushAndRemoveUntil(
      PageRouteInfo<dynamic> route, BuildContext context) async {
    context.router.pushAndPopUntil(
      route,
      predicate: (bool) => false,
      onFailure: (NavigationFailure failure) {
        if (failure == RouteNotFoundFailure) {
        } else if (failure == RejectedByGuardFailure) {}
      },
    );
  }

  @override
  void pushNamed() {}

  @override
  void pushNamedReplace(BuildContext context) {}

  @override
  void pushReplace(PageRouteInfo<dynamic> route, context) {
    context.router.replace(route, onFailure: (NavigationFailure failure) {
      if (failure == RouteNotFoundFailure) {
      } else if (failure == RejectedByGuardFailure) {}
    });
  }
}
