import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/demo_hive_store.dart';
import '../routing/demo_routes.dart';
import '../services/demo_session.dart';

class DemoBootstrap {
  DemoBootstrap._();

  static Future<void> start(BuildContext context) async {
    await DemoHiveStore.instance.resetToSeed();
    DemoSession.activate();
    if (context.mounted) {
      context.go(DemoRoutes.home);
    }
  }

  static Future<void> stop(BuildContext context) async {
    await DemoHiveStore.instance.endSession();
    DemoSession.deactivate();
    if (context.mounted) {
      context.go('/home');
    }
  }
}
