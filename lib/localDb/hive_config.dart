import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_string_constants.dart';
import 'token/login_token_box.dart';
import 'token/login_token_model.dart';

class AppHiveConfig {
  AppHiveConfig._();

  static Future<void> init() async {
    if (!kIsWeb) {
      Directory directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }
    Hive.registerAdapter(SaveLoginTokenModelAdapter());
    await Future.wait([
      Hive.openBox(AppStringConstants.hiveBoxKey),
      Hive.openBox(SaveTokenBox.loginTokenBoxKey),
    ]);
  }
}
