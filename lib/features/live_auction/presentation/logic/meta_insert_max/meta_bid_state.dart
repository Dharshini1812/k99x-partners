// lib/features/meta_bid/presentation/logic/meta_bid_state.dart

import 'package:dealer/features/live_auction/data/model/meta_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta_bid_state.freezed.dart';

@freezed
class MetaHighestBidState with _$MetaHighestBidState {
  const factory MetaHighestBidState.initial() = _Initial;
  const factory MetaHighestBidState.loading() = _Loading;
  const factory MetaHighestBidState.loaded(MetaBidData data) = _Loaded;
  const factory MetaHighestBidState.error(String message) = _Error;
}

@freezed
class InsertMetaBidState with _$InsertMetaBidState {
  const factory InsertMetaBidState.initial() = _InsertInitial;
  const factory InsertMetaBidState.submitting() = _Submitting;
  const factory InsertMetaBidState.success(MetaBidData data, String message) =
      _InsertSuccess;
  const factory InsertMetaBidState.error(String message) = _InsertError;
}
