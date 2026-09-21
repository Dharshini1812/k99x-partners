class LocationOption {
  final String id;
  final String name;

  LocationOption({required this.id, required this.name});

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    final id =
        json['id'] ?? json['stateId'] ?? json['cityId'] ?? json['value'] ?? '';
    final name = json['name'] ??
        json['stateName'] ??
        json['cityName'] ??
        json['label'] ??
        '';
    return LocationOption(id: '$id', name: '$name');
  }

  @override
  String toString() => name;
}
