import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../constants/app_string_constants.dart';
import 'login_token_model.dart';

class SaveTokenBox with AppStringConstants {
  static const String hiveBoxKey = AppStringConstants.hiveBoxKey;
  static const String loginTokenBoxKey = AppStringConstants.credentialsBoxKey;
  late Box _loginTokenBox;
  SaveTokenBox._() {
    _loginTokenBox = Hive.box(hiveBoxKey);
  }
  static final SaveTokenBox _singleton = SaveTokenBox._();
  factory SaveTokenBox() => _singleton;

  ///for public use
  static SaveTokenBox get loginTokenBox => _singleton;

  ///save data to db
  set saveLoginToken(SaveLoginTokenModel value) {
    _loginTokenBox.put(loginTokenBoxKey, value).catchError(
      (error, stack) {
        if (kDebugMode) debugPrint("Hive Token saving error >>, $error  $stack");
      },
    );
  }

  ///fetch data from db
  SaveLoginTokenModel? get fetchLoginToken {
    late SaveLoginTokenModel? value;
    try {
      value = _loginTokenBox.get(loginTokenBoxKey);
      return value;
    } catch (e) {
      if (kDebugMode) debugPrint("Hive Token fetching error >> >>, $e");
      return value;
    }
  }

  Future<void> clearLoginToken() async {
    try {
      await _loginTokenBox.clear();
    } catch (e) {
      if (kDebugMode) debugPrint("Hive Token clearing error >>, $e");
    }
  }
}
