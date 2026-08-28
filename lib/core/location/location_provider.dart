// lib/core/location/location_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({required this.latitude, required this.longitude});
}

enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown
}

class LocationState {
  final UserLocation? location;
  final bool isLoading;
  final LocationFailure? failure;

  const LocationState({this.location, this.isLoading = false, this.failure});

  LocationState copyWith({
    UserLocation? location,
    bool? isLoading,
    LocationFailure? failure,
    bool clearFailure = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// Call this once after login (or from dashboard initState if you'd
  /// rather ask there). Safe to call again later — it just re-fetches.
  Future<void> fetchLocation() async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoading: false,
        failure: LocationFailure.serviceDisabled,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          failure: LocationFailure.permissionDenied,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoading: false,
        failure: LocationFailure.permissionDeniedForever,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      state = state.copyWith(
        isLoading: false,
        location: UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        failure: LocationFailure.unknown,
      );
    }
  }

  /// Straight-line distance in km between the user and a vehicle's
  /// lat/lng, if you have per-vehicle coordinates. If your vehicle data
  /// only carries cityId/stateId (as in this app's model), you'd instead
  /// match on that — see note below.
  double? distanceToKm(double? vehicleLat, double? vehicleLng) {
    final loc = state.location;
    if (loc == null || vehicleLat == null || vehicleLng == null) return null;
    return Geolocator.distanceBetween(
          loc.latitude,
          loc.longitude,
          vehicleLat,
          vehicleLng,
        ) /
        1000;
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (_) => LocationNotifier(),
);
