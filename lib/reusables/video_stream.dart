import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

class IframeVideoContainer extends StatefulWidget {
  const IframeVideoContainer({super.key, required this.videoUrl, this.width, this.height});
  final String videoUrl;
  final double? width;
  final double? height;
  @override
  State<IframeVideoContainer> createState() => _IframeVideoContainerState();
}

class _IframeVideoContainerState extends State<IframeVideoContainer> {
  late final String _viewType;
  late final web.HTMLIFrameElement _iframeElement;
  @override
  Widget build(BuildContext context) {
    final Widget htmlView = HtmlElementView(viewType: _viewType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasParentConstraint = constraints.maxWidth.isFinite || constraints.maxHeight.isFinite;

        if (hasParentConstraint) {
          return SizedBox(
            width: widget.width ?? (constraints.maxWidth == double.infinity ? null : constraints.maxWidth),
            height: widget.height ?? (constraints.maxHeight == double.infinity ? null : constraints.maxHeight),
            child: htmlView,
          );
        }

        return SizedBox(
          width: widget.width,
          child: AspectRatio(aspectRatio: 16 / 9, child: htmlView),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _viewType = 'iframe-${widget.videoUrl.hashCode}';
    _iframeElement = web.HTMLIFrameElement()
      ..src = widget.videoUrl
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block';
    _iframeElement.setAttribute('allowfullscreen', '');

    // Register the view factory once for this viewType
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _iframeElement);
  }

  @override
  void didUpdateWidget(covariant IframeVideoContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      // Update the iframe src without recreating the element
      _iframeElement.src = widget.videoUrl;
    }
  }

  @override
  void dispose() {
    // No-op: platform view registry does not provide an unregister API.
    super.dispose();
  }
}
