import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dLogic = ChangeNotifierProvider((ref) => DashBoardLogic(ref));

class DashBoardLogic extends ChangeNotifier {
  final Ref ref;

  DashBoardLogic(this.ref) {
    loadUser();
  }

  UserData? _user;
  UserData? get user => _user;

  Future<void> loadUser() async {
    _user = await SecureStorageService().getUser();
    notifyListeners();
  }

  void setUser(UserData user) {
    _user = user;
    notifyListeners();
  }
}
