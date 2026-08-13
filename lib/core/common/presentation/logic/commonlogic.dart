import 'dart:async';
import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cLogic = ChangeNotifierProvider((ref) => CommonLogic(ref: ref));
String? _mapFuel(String? fuel) {
  switch (fuel?.toUpperCase()) {
    case "PETROL":
      return "Petrol";

    case "DIESEL":
      return "Diesel";

    case "CNG":
      return "CNG";

    case "LPG":
      return "LPG";

    case "ELECTRIC":
      return "Electric";

    default:
      return null;
  }
}

String? _mapBodyStyle(String? body) {
  switch (body?.toUpperCase()) {
    case "OPEN":
      return "Truck";

    case "HATCHBACK":
      return "Hatchback";

    case "SEDAN":
      return "Sedan";

    case "SUV":
      return "SUV";

    default:
      return null;
  }
}

class CommonLogic extends ChangeNotifier {
  final Ref ref;

  bool loading = false;
  String? error;

  RCDetailsModel? rcDetails;
  bool isValid(String regNo) {
    return RegExp(
      r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}$',
    ).hasMatch(
      regNo.replaceAll(" ", "").toUpperCase(),
    );
  }

  Future<void> fetchRc(String regNo) async {
    final vehicleNo = regNo.replaceAll(" ", "").toUpperCase();

    if (!isValid(vehicleNo)) {
      error = "Invalid Registration Number";
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      // THIS CALLS THE DATASOURCE
      final rc = await ref.read(getRcProvider.notifier).getRcDetails(vehicleNo);

      rcDetails = rc;

      _autoFill(rc);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _autoFill(RCDetailsModel rc) async {
    final notifier = ref.read(listingProvider.notifier);

    //---------------------------------------
    // 1. Basic Fields
    //---------------------------------------

    String? year;

    if (rc.manufacturedMonthYear != null &&
        rc.manufacturedMonthYear!.contains('/')) {
      year = rc.manufacturedMonthYear!.split('/').last;
    }

    notifier.update(
      (s) => s.copyWith(
        registrationNumber: rc.registrationNumber,
        year: year,
        fuelType: _mapFuel(rc.fuelDescription),
        bodyStyle: _mapBodyStyle(rc.bodyTypeDescription),
        numberOfOwners: rc.ownerSerialNumber?.toString(),
      ),
    );

    //---------------------------------------
    // 2. MAKE
    //---------------------------------------

    final makeState = ref.read(getMakeProvider);

    final makeList = makeState.maybeWhen(
      data: (list) => list,
      orElse: () => <MakeModel>[],
    );

    MakeModel? make;

    try {
      make = makeList.firstWhere(
        (e) => (rc.makerDescription ?? "")
            .toUpperCase()
            .contains((e.name ?? "").toUpperCase()),
      );
    } catch (_) {
      make = null;
    }

    if (make != null) {
      notifier.update(
        (s) => s.copyWith(make: make),
      );

      //---------------------------------------
      // Load Models
      //---------------------------------------

      await ref.read(getModelProvider.notifier).getModel(makeId: make.sno ?? 0);

      await Future.delayed(const Duration(milliseconds: 300));
    }

    //---------------------------------------
    // 3. MODEL
    //---------------------------------------

    ModelModel? model;

    if (make != null) {
      final modelState = ref.read(getModelProvider);

      final modelList = modelState.maybeWhen(
        data: (list) => list,
        orElse: () => <ModelModel>[],
      );

      try {
        model = modelList.firstWhere(
          (e) => (rc.makerModel ?? "")
              .toUpperCase()
              .contains((e.name ?? "").toUpperCase()),
        );
      } catch (_) {
        model = null;
      }

      if (model != null) {
        notifier.update(
          (s) => s.copyWith(model: model),
        );

        //---------------------------------------
        // Load Variant
        //---------------------------------------

        await ref
            .read(getVariantProvider.notifier)
            .getVariants(modelId: model.sno ?? 0);

        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    //---------------------------------------
    // 4. VARIANT
    //---------------------------------------

    if (model != null) {
      final variantState = ref.read(getVariantProvider);

      final variantList = variantState.maybeWhen(
        data: (list) => list,
        orElse: () => <VariantModel>[],
      );

      if (variantList.isNotEmpty) {
        notifier.update(
          (s) => s.copyWith(
            variant: variantList.first,
          ),
        );
      }
    }

    //---------------------------------------
    // 5. STATE
    //---------------------------------------

    final stateState = ref.read(getStateProvider);

    final stateList = stateState.when(
      initial: () => <StateModel>[],
      loading: () => <StateModel>[],
      error: (_) => <StateModel>[],
      data: (list) => list,
    );

    StateModel? state;

    if (rc.registeredAt != null) {
      for (final s in stateList) {
        if (rc.registeredAt!
            .toUpperCase()
            .contains((s.stateName ?? "").toUpperCase())) {
          state = s;
          break;
        }
      }
    }

    if (state != null) {
      notifier.update(
        (s) => s.copyWith(
          selectedState: state,
        ),
      );

      //---------------------------------------
      // Load Cities
      //---------------------------------------

      await ref.read(getCityProvider.notifier).getCity(
            id: state.eqStateId.toString(),
          );

      await Future.delayed(const Duration(milliseconds: 300));
    }

    //---------------------------------------
    // 6. CITY
    //---------------------------------------

    if (state != null) {
      final cityState = ref.read(getCityProvider);

      final cityList = cityState.when(
        initial: () => <CityModel>[],
        loading: () => <CityModel>[],
        error: (_) => <CityModel>[],
        data: (list) => list,
      );

      CityModel? city;

      if (rc.registeredAt != null) {
        for (final c in cityList) {
          if (rc.registeredAt!
              .toUpperCase()
              .contains((c.cityName ?? "").toUpperCase())) {
            city = c;
            break;
          }
        }
      }

      if (city != null) {
        notifier.update(
          (s) => s.copyWith(
            selectedCity: city,
          ),
        );
      }
    }

    notifyListeners();
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  CommonLogic({required this.ref});
}
