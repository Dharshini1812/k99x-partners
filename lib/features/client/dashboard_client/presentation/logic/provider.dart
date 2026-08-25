// lib/features/client/presentation/logic/client_providers.dart

import 'package:dealer/features/client/dashboard_client/data/datasource/remote_datasource.dart';
import 'package:dealer/features/client/dashboard_client/data/repository/repository_impl.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_kyc_view.dart';
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_loan_approval.dart';
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_stocks.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/c_stocks/c_stock_notifier.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/c_stocks/c_stocks_state.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_kyc_view/client_kyc_notifier.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_kyc_view/client_kyc_state.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_loan_approval/client_loan_approval_state.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_loan_approval/client_loan_notifier.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/getdashboard_stats.dart/c_stats_notifier.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/getdashboard_stats.dart/c_stats_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientDataSourceProvider = Provider<ClientDataSource>(
  (ref) => ClientDatasourceImpl(ref),
);

final clientRepositoryProvider = Provider<ClientRepository>(
  (ref) => ClientRepositoryImpl(ref.read(clientDataSourceProvider)),
);

final getClientDashboardUsecase = Provider<GetClientDashboard>(
  (ref) => GetClientDashboard(ref.read(clientRepositoryProvider)),
);

final getClientStocksUsecase = Provider<GetClientStocks>(
  (ref) => GetClientStocks(ref.read(clientRepositoryProvider)),
);

final clientDashboardNotifierProvider =
    StateNotifierProvider<ClientDashboardNotifier, ClientDashboardState>(
  (ref) => ClientDashboardNotifier(
    usecase: ref.read(getClientDashboardUsecase),
  ),
);

final clientStocksNotifierProvider =
    StateNotifierProvider<ClientStocksNotifier, ClientStocksState>(
  (ref) => ClientStocksNotifier(
    usecase: ref.read(getClientStocksUsecase),
  ),
);

final approveLoanUsecase = Provider<ApproveLoan>(
  (ref) => ApproveLoan(ref.read(clientRepositoryProvider)),
);

final getClientKycViewUsecase = Provider<GetClientKycView>(
  (ref) => GetClientKycView(ref.read(clientRepositoryProvider)),
);

final loanApproveNotifierProvider =
    StateNotifierProvider<LoanApproveNotifier, LoanApproveState>(
  (ref) => LoanApproveNotifier(usecase: ref.read(approveLoanUsecase)),
);

final clientKycViewNotifierProvider =
    StateNotifierProvider<ClientKycViewNotifier, ClientKycViewState>(
  (ref) => ClientKycViewNotifier(usecase: ref.read(getClientKycViewUsecase)),
);
