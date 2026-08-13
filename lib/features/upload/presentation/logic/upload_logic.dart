import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadLogic = ChangeNotifierProvider((ref) => UploadLogic(ref: ref));

class UploadLogic extends ChangeNotifier {
  final Ref ref;

  UploadLogic({required this.ref});

  final bodyStyleOptions = [
    'Sedan',
    'SUV',
    'Coupe',
    'Truck',
  ];

  final fuelOptions = [
    'Petrol',
    'Diesel',
    'CNG',
    'Electric',
    'Hybrid',
  ];

  final transmissionOptions = [
    'Manual',
    'Automatic',
  ];
  final kConditionOptions = ['Excellent', 'Good', 'Average', 'Poor', 'Bad'];
  final kAccidentOptions = ['No Accidents', 'Minor Accident', 'Major Accident'];
  final yearOptions = List.generate(
    DateTime.now().year - 1996 + 1,
    (index) => (1996 + index).toString(),
  ).reversed.toList();
}
