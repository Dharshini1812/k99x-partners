class OcbVehicle {
  final String id, title, city, regNo, fuelType, transmission, ownerLabel;
  final String? imageUrl;
  final int km;
  final double ocbPrice, quoteFromPrice;
  final double? extScore, engScore;
  final DateTime priceValidUntil;

  OcbVehicle({
    required this.id,
    required this.title,
    required this.city,
    required this.regNo,
    required this.fuelType,
    required this.transmission,
    required this.ownerLabel,
    required this.km,
    this.imageUrl,
    required this.ocbPrice,
    required this.quoteFromPrice,
    this.extScore,
    this.engScore,
    required this.priceValidUntil,
  });

  factory OcbVehicle.fromJson(Map<String, dynamic> j) => OcbVehicle(
        id: j['id'].toString(),
        title: j['title'],
        city: j['city'],
        regNo: j['regNo'] ?? 'UNREGISTERED',
        fuelType: j['fuelType'],
        transmission: j['transmission'],
        ownerLabel: j['ownerLabel'],
        km: j['km'],
        imageUrl: j['imageUrl'],
        ocbPrice: (j['ocbPrice'] as num).toDouble(),
        quoteFromPrice: (j['quoteFromPrice'] as num).toDouble(),
        extScore: (j['extScore'] as num?)?.toDouble(),
        engScore: (j['engScore'] as num?)?.toDouble(),
        priceValidUntil: DateTime.parse(j['priceValidUntil']),
      );
}
