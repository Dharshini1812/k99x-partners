import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:dealer/features/my_listings/domain/usecase/add_kyc.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_kyc/add_kyc_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddKycNotifier extends StateNotifier<AddKycState> {
  final Addkyc _addKycUsecase;

  AddKycNotifier({
    required Addkyc addKycUsecase,
    AddKycState? initialState,
  })  : _addKycUsecase = addKycUsecase,
        super(initialState ?? const AddKycState.initial());

  Future<KycSubmitResponse?> addKyc({KycSubmitRequest? data}) async {
    state = const AddKycState.loading();

    try {
      final result = await _addKycUsecase.addKyc(data);

      return result.fold(
        (failure) {
          state = AddKycState.error(failure.msg ?? '');
          return null;
        },
        (response) {
          state = AddKycState.data(response);
          return response;
        },
      );
    } catch (e) {
      state = AddKycState.error(e.toString());
      return null;
    }
  }
}
