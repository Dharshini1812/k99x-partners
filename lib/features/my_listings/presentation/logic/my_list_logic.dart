import 'package:dealer/core/common/data/model/car_make.dart';
import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myListLogic = ChangeNotifierProvider((ref) => MyListLogic(ref: ref));

class MyListLogic extends ChangeNotifier {
  final Ref ref;
  int selectedMake = 0;
  final List<CarMake> makes = [
    const CarMake(name: "All", logo: "assets/logos/all.png"),
    const CarMake(name: "Tata", logo: "assets/logos/tata.png"),
    const CarMake(name: "Hyundai", logo: "assets/logos/hyundai.png"),
    const CarMake(name: "Maruti", logo: "assets/logos/maruti.png"),
    const CarMake(name: "Honda", logo: "assets/logos/honda.png"),
    const CarMake(name: "Mahindra", logo: "assets/logos/mahindra.png"),
    const CarMake(name: "Toyota", logo: "assets/logos/toyota.png"),
  ];
  void applyFilter(LiveStockFilter filter) {
    // filter _originalList
  }
  MyListLogic({required this.ref});
}
