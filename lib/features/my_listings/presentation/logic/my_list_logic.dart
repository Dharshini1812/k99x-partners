import 'package:dealer/core/common/data/model/car_make.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myListLogic = ChangeNotifierProvider((ref) => MyListLogic(ref: ref));

class MyListLogic extends ChangeNotifier {
  final Ref ref;
  int selectedMake = 0;
  final List<CarMake> makes = [
    CarMake(name: "All", logo: "assets/logos/all.png"),
    CarMake(name: "Tata", logo: "assets/logos/tata.png"),
    CarMake(name: "Hyundai", logo: "assets/logos/hyundai.png"),
    CarMake(name: "Maruti", logo: "assets/logos/maruti.png"),
    CarMake(name: "Honda", logo: "assets/logos/honda.png"),
    CarMake(name: "Mahindra", logo: "assets/logos/mahindra.png"),
    CarMake(name: "Toyota", logo: "assets/logos/toyota.png"),
  ];

  MyListLogic({required this.ref});
}
