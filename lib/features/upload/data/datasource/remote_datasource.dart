import 'dart:developer';

import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/data/model/edit_vehicle_response_model.dart';
import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class UploadDatasource {
  Future<UploadModel> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  });
  Future<AddVehicleResponseModel> addVehicleData(
      AddVehicleRequestModel formData);
  Future<ReviewResponseModel> getVehicleReview(String vehicleId);
  Future<CompleteVehicleResponseModel> completeVehicleListing(
      CompleteVehicleRequestModel request);
  Future<EditVehicleResponseModel> getVehicleForEdit(String vehicleId);
}

class UploadDatasourceImpl implements UploadDatasource {
  final Ref ref;

  UploadDatasourceImpl({required this.ref});

  @override
  Future<UploadModel> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  }) async {
    final response = await ref.read(apiService).uploadImage(
          url: Url.uploadUrl,
          vehicleId: vehicleId,
          imageType: mediaType,
          filePath: filePath,
        );

    return UploadModel.fromJson(response.data);
  }

  @override
  Future<AddVehicleResponseModel> addVehicleData(
      AddVehicleRequestModel request) async {
    try {
      const url = Url.uploadVehicleW;
      final response =
          await ref.read(apiService).postMultipart(url, request.toFormData());

      return AddVehicleResponseModel.fromJson(
        response.data,
      );
    } catch (e) {
      log("Add Error : $e");
      rethrow;
    }
  }

  @override
  Future<ReviewResponseModel> getVehicleReview(String vehicleId) async {
    try {
      final api = ref.read(apiService);
      // ADAPT: confirm Url.vehicleReviewUrl matches your Url class's
      // naming convention (e.g. Url.uploadVehicleW, Url.uploadKyc).
      final response = await api.get1(
        "${Url.vehicleReviewUrl}?vehicleId=$vehicleId",
      );

      // get1 returns the full Dio Response — the JSON body is in
      // response.data, not the Response wrapper itself.
      return ReviewResponseModel.fromJson(response.data);
    } catch (e) {
      log("Vehicle Review Error : $e");
      rethrow;
    }
  }

  @override
  Future<CompleteVehicleResponseModel> completeVehicleListing(
      CompleteVehicleRequestModel request) async {
    try {
      final api = ref.read(apiService);
      // ADAPT: confirm Url.completeVehicleUrl.
      final response = await api.postMultipart(
        Url.completeVehicleUrl,
        request.toFormData(),
      );

      return CompleteVehicleResponseModel.fromJson(response.data);
    } catch (e) {
      log("Complete Vehicle Error : $e");
      rethrow;
    }
  }

  @override
  Future<EditVehicleResponseModel> getVehicleForEdit(String vehicleId) async {
    try {
      final api = ref.read(apiService);
      // ADAPT: confirm Url.editVehicleUrl matches your Url class's
      // naming convention.
      final response = await api.get1(
        "${Url.editVehicleurl}?vehicleId=$vehicleId",
      );

      // get1 returns the full Dio Response — body is in response.data.
      return EditVehicleResponseModel.fromJson(response.data);
    } catch (e) {
      log("Get Vehicle For Edit Error : $e");
      rethrow;
    }
  }
}
