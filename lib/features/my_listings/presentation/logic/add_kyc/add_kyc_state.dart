import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'add_kyc_state.freezed.dart';

@freezed
class AddKycState with _$AddKycState {
  const factory AddKycState.initial() = _AddKycStateInitial;
  const factory AddKycState.loading() = _AddKycStateLoading;
  const factory AddKycState.data(KycSubmitResponse data) = _AddKycStateData;
  const factory AddKycState.error(String msg) = _AddKycStateError;
}
