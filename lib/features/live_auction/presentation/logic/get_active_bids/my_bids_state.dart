// lib/features/my_bids/presentation/logic/my_bids_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_bids_state.freezed.dart';

@freezed
class MyBidsState<T> with _$MyBidsState<T> {
  const factory MyBidsState.initial() = _Initial<T>;
  const factory MyBidsState.loading() = _Loading<T>;
  const factory MyBidsState.loaded(T data) = _Loaded<T>;
  const factory MyBidsState.error(String message) = _Error<T>;
}
