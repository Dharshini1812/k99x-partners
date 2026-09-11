import '../repository/repository.dart';
import '../../data/model/a_vehicle_detail.dart';

class GetVehicleDetailUseCase {
  final AuctionRepository repository;

  GetVehicleDetailUseCase(this.repository);

  Future<VehicleDetailResponse> call(String vehicleId) async {
    return await repository.getVehicleDetail(vehicleId);
  }
}
