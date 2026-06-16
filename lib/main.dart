import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:universal_html/html.dart' as html;

import 'constants/app_string_constants.dart';
import 'localDb/hive_config.dart';
import 'services/app_config.dart';
import 'services/lifecycle_observer.dart';
import 'wrapper/main_app_bloc_provider.dart';
import 'wrapper/main_app_view.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    initializeDateFormatting();
    setUrlStrategy(PathUrlStrategy());
    appConfig = AppConfig(
      debugMode: kDebugMode ? "true" : "false",
      operatingSystem: getUserAgentType(),
      dated: AppStringConstants.dated,
      appName: Uri.base.toString(),
      version: AppStringConstants.version,
      packageName: Uri.base.toString(),
      buildNumber: int.tryParse(AppStringConstants.buildNumber) ?? 1,
    );

    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }

    await AppHiveConfig.init();

    runApp(const MainApp());
  }, (error, stack) {
    debugPrint("Zoned Error\nerror: $error\nstackTrace: $stack");
  });
}

String getUserAgentType() {
  if (kIsWeb) {
    final ua = html.window.navigator.userAgent.toLowerCase();
    if (ua.contains("mobile") || ua.contains("android") || ua.contains("iphone")) {
      return "Browser (mobile)";
    } else {
      return "Browser (desktop)";
    }
  } else {
    if (Platform.isAndroid || Platform.isIOS) {
      return "App (mobile)";
    } else {
      return "App (desktop)";
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MainAppBlocProvider(
      child: LifeCycleObserver(
        child: MainAppView(),
      ),
    );
  }
}
