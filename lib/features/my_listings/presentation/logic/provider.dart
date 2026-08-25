import 'package:dealer/features/my_listings/data/datasource/remote_datasource.dart';
import 'package:dealer/features/my_listings/data/repository/repository_impl.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';
import 'package:dealer/features/my_listings/domain/usecase/add_kyc.dart';
import 'package:dealer/features/my_listings/domain/usecase/add_wanted.dart';
import 'package:dealer/features/my_listings/domain/usecase/live_stock.dart';
import 'package:dealer/features/my_listings/domain/usecase/my_stock.dart';
import 'package:dealer/features/my_listings/domain/usecase/wanted_list.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_kyc/add_kyc_notifier.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_kyc/add_kyc_state.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_wanted/add_wanted_notifier.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_wanted/add_wanted_state.dart';
import 'package:dealer/features/my_listings/presentation/logic/live_list/live_list_notifier.dart';
import 'package:dealer/features/my_listings/presentation/logic/live_list/live_list_state.dart';
import 'package:dealer/features/my_listings/presentation/logic/my_list/my_list_notifier.dart';
import 'package:dealer/features/my_listings/presentation/logic/my_list/my_list_state.dart';
import 'package:dealer/features/my_listings/presentation/logic/wanted_list/wanted_list_notifier.dart';
import 'package:dealer/features/my_listings/presentation/logic/wanted_list/wanted_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _listingDatasource =
    Provider<ListingDataSource>((ref) => ListingDatasourceImpl(ref));

final _listingRepository = Provider<MyListingsRepository>((ref) =>
    MyListingsRepositoryImpl(dataSource: ref.read(_listingDatasource)));

final _listingUsecase = Provider<MyListUsecase>(
    (ref) => MyListUsecase(repository: ref.read(_listingRepository)));

final _livelistingUsecase = Provider<LiveListUsecase>(
    (ref) => LiveListUsecase(repository: ref.read(_listingRepository)));

final myStockNotifierProvider =
    StateNotifierProvider<MyStockNotifier, MyListState>(
        (ref) => MyStockNotifier(getMyStockUsecase: ref.read(_listingUsecase)));

final liveStockNotifier =
    StateNotifierProvider<LiveStockNotifier, LiveListState>((ref) =>
        LiveStockNotifier(getLiveStockUsecase: ref.read(_livelistingUsecase)));

final _addKycUsecase =
    Provider<Addkyc>((ref) => Addkyc(repository: ref.read(_listingRepository)));

final addKycNotifier = StateNotifierProvider<AddKycNotifier, AddKycState>(
    (ref) => AddKycNotifier(addKycUsecase: ref.read(_addKycUsecase)));

final _wantedListUsecase = Provider<WantedList>(
    (ref) => WantedList(listingsRepository: ref.read(_listingRepository)));

final wantedListProvider =
    StateNotifierProvider<WantedListNotifier, WantedListState>((ref) =>
        WantedListNotifier(wantedUsecase: ref.read(_wantedListUsecase)));

final _saveWantedListingUsecase = Provider<SaveWantedListing>(
  (ref) => SaveWantedListing(ref.read(_listingRepository)),
);
final wantedSaveProvider =
    StateNotifierProvider<WantedSaveNotifier, WantedSaveState>(
  (ref) => WantedSaveNotifier(usecase: ref.read(_saveWantedListingUsecase)),
);
