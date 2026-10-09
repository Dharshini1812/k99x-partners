class WatchlistUpdateRequestModel {
  final String vehicleId;
  final int watchlist; // 1 to add, 0 to remove

  WatchlistUpdateRequestModel({
    required this.vehicleId,
    required this.watchlist,
  });

  Map<String, dynamic> toQueryParams() => {
        'vehicleId': vehicleId,
        'watchlist': watchlist.toString(),
      };
  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'watchlist': watchlist,
      };
}
