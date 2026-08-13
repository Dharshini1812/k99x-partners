class LiveStockFilter {
  final String? query;
  final String? make;
  final String? model;
  final int? year;
  final int? owner;
  final String? stockAge;
  final double? minKm;
  final double? maxKm;

  const LiveStockFilter({
    this.query,
    this.make,
    this.model,
    this.year,
    this.owner,
    this.stockAge,
    this.minKm,
    this.maxKm,
  });
}
