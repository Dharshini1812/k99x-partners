// import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
// import 'package:dealer/features/live_auction/data/model/auction_vehicle.dart';
// import 'package:dealer/features/live_auction/data/model/ocb_vehicle.dart';
// import 'package:dio/dio.dart';

// abstract class AuctionApi {
//   Future<List<AuctionVehicle>> fetchAuctions({int page = 1, int limit = 10});
//   Future<List<OcbVehicle>> fetchOneClickBuy({int page = 1, int limit = 10});
//   Future<VehicleDetail> fetchVehicleDetail(String id);
// }

// class RemoteAuctionApi implements AuctionApi {
//   final Dio dio;
//   RemoteAuctionApi(this.dio);

//   @override
//   Future<List<AuctionVehicle>> fetchAuctions(
//       {int page = 1, int limit = 10}) async {
//     final res = await dio
//         .get('/auctions/live', queryParameters: {'page': page, 'limit': limit});
//     return (res.data['data'] as List)
//         .map((e) => AuctionVehicle.fromJson(e))
//         .toList();
//   }

//   @override
//   Future<List<OcbVehicle>> fetchOneClickBuy(
//       {int page = 1, int limit = 10}) async {
//     final res = await dio.get('/auctions/one-click-buy',
//         queryParameters: {'page': page, 'limit': limit});
//     return (res.data['data'] as List)
//         .map((e) => OcbVehicle.fromJson(e))
//         .toList();
//   }

//   @override
//   Future<VehicleDetail> fetchVehicleDetail(String id) async {
//     final res = await dio.get('/vehicles/$id');
//     return VehicleDetail.fromJson(res.data['data']);
//   }
// }
