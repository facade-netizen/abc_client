import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

import '../reusables/colors.dart';

class RightClickService {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required Offset position,
    required String route,
  }) {
    hide();

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox;

    /// 🔥 Convert global → local overlay position
    final localPosition = overlayBox.globalToLocal(position);

    double dx = localPosition.dx;
    double dy = localPosition.dy;

    double menuWidth = 200;
    double menuHeight = 50; // approx height of menu

    final screenSize = overlayBox.size;

    /// 🔥 Prevent overflow (right side)
    if (dx + menuWidth > screenSize.width) {
      dx = screenSize.width - menuWidth - 10;
    }

    /// 🔥 Prevent overflow (bottom side)
    if (dy + menuHeight > screenSize.height) {
      dy = screenSize.height - menuHeight - 10;
    }

    /// 🔥 Slight upward adjustment (like Chrome feel)
    dy = dy - 5;

    _currentOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            /// Click outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(),
              ),
            ),

            /// Context Menu
            Positioned(
              left: dx,
              top: dy,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _menuItem("Open in new tab", () {
                        hide();
                        _openInNewTab(route);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static Widget _menuItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.open_in_new, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(color: black),
            ),
          ],
        ),
      ),
    );
  }

  static void _openInNewTab(String route) {
    html.window.open(route, '_blank');
  }
}

class RightClickWrapper extends StatelessWidget {
  final Widget child;
  final String route;

  const RightClickWrapper({
    super.key,
    required this.child,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        RightClickService.show(
          context: context,
          position: details.globalPosition,
          route: route,
        );
      },
      child: child,
    );
  }
}
