import 'package:flutter/material.dart';

import '../routing/app_router.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({super.key, required this.mobile, this.tablet, required this.desktop});

  // This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 700;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width < 1100 && MediaQuery.sizeOf(context).width >= 700;

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    // If our width is more than 1100 then we consider it a desktop
    if (size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}

Widget responsiveBuilder({required BuildContext context, required Widget mobile, required Widget desktop}) {
  if (Responsive.isMobile(context)) {
    disconnectPrevSignalRConnection(null, context);
    return mobile;
  } else {
    return desktop;
  }
}
