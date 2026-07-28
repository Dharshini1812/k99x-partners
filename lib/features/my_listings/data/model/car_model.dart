class Car {
  final String id;
  final String title;
  final String year;
  final String model;
  final String variant;
  final String fuelType;
  final String transmission;
  final String type;
  final int mileage; // in km
  final int owners;
  final String stockId;
  final String registrationNumber;
  final String location;
  final double sellingPrice;
  final double valuationPrice;
  final double avgSellingPrice;
  final double lastSoldPrice;
  final double exteriorRating;
  final double interiorRating;
  final double engineRating;
  final DateTime listedDate;
  final String? imageUrl;
  final bool isLive;
  final int? ratingAdjustment; // -1, 0, +1, +5, etc.

  const Car({
    required this.id,
    required this.title,
    required this.year,
    required this.model,
    required this.variant,
    required this.fuelType,
    required this.transmission,
    required this.type,
    required this.mileage,
    required this.owners,
    required this.stockId,
    required this.registrationNumber,
    required this.location,
    required this.sellingPrice,
    required this.valuationPrice,
    required this.avgSellingPrice,
    required this.lastSoldPrice,
    required this.exteriorRating,
    required this.interiorRating,
    required this.engineRating,
    required this.listedDate,
    this.imageUrl,
    this.isLive = true,
    this.ratingAdjustment,
  });

  String get shortSpecs =>
      '$fuelType · $transmission · $type · $mileage km · $owners Owner${owners > 1 ? 's' : ''}';

  String get formattedSellingPrice => _formatPrice(sellingPrice);
  String get formattedValuationPrice => _formatPrice(valuationPrice);
  String get formattedAvgSellingPrice => _formatPrice(avgSellingPrice);
  String get formattedLastSoldPrice =>
      lastSoldPrice == 0 ? '₹0' : _formatPrice(lastSoldPrice);

  static String _formatPrice(double price) {
    if (price == 0) return '₹0';
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')} L';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  Car copyWith({
    String? id,
    String? title,
    String? year,
    String? model,
    String? variant,
    String? fuelType,
    String? transmission,
    String? type,
    int? mileage,
    int? owners,
    String? stockId,
    String? registrationNumber,
    String? location,
    double? sellingPrice,
    double? valuationPrice,
    double? avgSellingPrice,
    double? lastSoldPrice,
    double? exteriorRating,
    double? interiorRating,
    double? engineRating,
    DateTime? listedDate,
    String? imageUrl,
    bool? isLive,
    int? ratingAdjustment,
  }) =>
      Car(
        id: id ?? this.id,
        title: title ?? this.title,
        year: year ?? this.year,
        model: model ?? this.model,
        variant: variant ?? this.variant,
        fuelType: fuelType ?? this.fuelType,
        transmission: transmission ?? this.transmission,
        type: type ?? this.type,
        mileage: mileage ?? this.mileage,
        owners: owners ?? this.owners,
        stockId: stockId ?? this.stockId,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        location: location ?? this.location,
        sellingPrice: sellingPrice ?? this.sellingPrice,
        valuationPrice: valuationPrice ?? this.valuationPrice,
        avgSellingPrice: avgSellingPrice ?? this.avgSellingPrice,
        lastSoldPrice: lastSoldPrice ?? this.lastSoldPrice,
        exteriorRating: exteriorRating ?? this.exteriorRating,
        interiorRating: interiorRating ?? this.interiorRating,
        engineRating: engineRating ?? this.engineRating,
        listedDate: listedDate ?? this.listedDate,
        imageUrl: imageUrl ?? this.imageUrl,
        isLive: isLive ?? this.isLive,
        ratingAdjustment: ratingAdjustment ?? this.ratingAdjustment,
      );
}
