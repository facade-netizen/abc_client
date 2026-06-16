import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void showSnackBar(BuildContext context, String title, {bool error = false}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  AnimatedSnackBar.material(
    title,
    duration: Duration(seconds: error ? 5 : 5),
    type: error ? AnimatedSnackBarType.error : AnimatedSnackBarType.success,
    desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
  ).show(context);
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<void> closeAllDialogs(BuildContext context) async {
  Navigator.of(context, rootNavigator: true).popUntil((route) => route is! PopupRoute);
}
