// lib/features/client/data/datasource/client_datasource.dart

import 'dart:developer';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ClientDataSource {
  Future<ClientDashboardResponseModel> getDashboard();
  Future<ClientStocksResponseModel> getStocks({
    required int page,
    int limit = 10,
  });
  Future<LoanApproveResponseModel> approveLoan(LoanApproveRequestModel request);
  Future<ClientKycViewResponseModel> getKycView(String vehicleId);
}

class ClientDatasourceImpl implements ClientDataSource {
  final Ref ref;
  ClientDatasourceImpl(this.ref);

  @override
  Future<ClientDashboardResponseModel> getDashboard() async {
    try {
      final api = ref.read(apiService);
      final response = await api.get1(Url.dashboardStatsUrl);
      return ClientDashboardResponseModel.fromJson(response.data);
    } catch (e) {
      log("Client Dashboard Error : $e");
      rethrow;
    }
  }

  @override
  Future<ClientStocksResponseModel> getStocks({
    required int page,
    int limit = 10,
  }) async {
    try {
      final api = ref.read(apiService);
      // NOTE: this endpoint paginates by page number, not offset — unlike
      // myStockUrl/liveStockUrl elsewhere in this app, which use
      // offset/limit. Don't copy-paste the offset pattern here.
      final response = await api.get1(
        "${Url.clientStocksUrl}?page=$page&limit=$limit",
      );
      return ClientStocksResponseModel.fromJson(response.data);
    } catch (e) {
      log("Client Stocks Error : $e");
      rethrow;
    }
  }

  @override
  Future<LoanApproveResponseModel> approveLoan(
      LoanApproveRequestModel request) async {
    try {
      final api = ref.read(apiService);
      // Plain JSON POST — the Postman request used Content-Type:
      // application/json and --body (not --form), so post1 is correct
      // here, not postMultipart.
      final response = await api.post1(Url.loanApproveUrl, request.toJson());
      return LoanApproveResponseModel.fromJson(response.data);
    } catch (e) {
      log("Loan Approve Error : $e");
      rethrow;
    }
  }

  @override
  Future<ClientKycViewResponseModel> getKycView(String vehicleId) async {
    try {
      final api = ref.read(apiService);
      final response = await api.get1("${Url.clientKycViewUrl}$vehicleId");
      return ClientKycViewResponseModel.fromJson(response.data);
    } catch (e) {
      log("Client KYC View Error : $e");
      rethrow;
    }
  }
}
