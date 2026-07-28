import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadLogic = ChangeNotifierProvider((ref) => UploadLogic(ref: ref));

class UploadLogic extends ChangeNotifier {
  final Ref ref;
  MakeModel? make;

  void setMake(MakeModel? value) {
    make = value;
    notifyListeners();
  }

  ModelModel? model;

  void setModel(ModelModel? value) {
    model = value;
    notifyListeners();
  }

  VariantModel? variant;

  void setVariant(VariantModel? value) {
    variant = value;
    notifyListeners();
  }

  StateModel? state;

  void setState(StateModel? value) {
    state = value;
    notifyListeners();
  }

  CityModel? city;

  void setCity(CityModel? value) {
    city = value;
    notifyListeners();
  }

  final makeOptions = ['ASTON MARTIN', 'BMW', 'AUDI'];
  final bodyStyleOptions = ['Sedan', 'SUV', 'Coupe', 'Truck'];
  final fuelOptions = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
  final transmissionOptions = ['Manual', 'Automatic'];
  final yearOptions = List.generate(
    DateTime.now().year - 1996 + 1,
    (index) => (1996 + index).toString(),
  ).reversed.toList();
  UploadLogic({required this.ref});
}
