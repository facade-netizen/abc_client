import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/universal_html.dart' as html;
import 'dart:ui_web' as ui;

import '../../../../blocs/fetchBlocs/fetch_lmt_match_id_bloc.dart';
import '../../../../constants/html_templates.dart';

class ScoreBoardStreamer extends StatefulWidget {
  const ScoreBoardStreamer({super.key, required this.eventId, required this.sportName});
  final String eventId;
  final String sportName;

  @override
  State<ScoreBoardStreamer> createState() => _ScoreBoardStreamerState();
}

class _ScoreBoardStreamerState extends State<ScoreBoardStreamer> {
  @override
  void initState() {
    context.read<FetchLMTMatchIdBloc>().add(FetchLMTMatchId(eventID: widget.eventId, sportName: widget.sportName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchLMTMatchIdBloc, FetchLMTMatchIdState>(
      builder: (context, state) {
        return state is FetchLMTMatchIdSuccess ? ScoreBoardIframe(eventId: state.matchId) : const SizedBox.shrink();
      },
    );
  }
}

class ScoreBoardIframe extends StatefulWidget {
  const ScoreBoardIframe({
    super.key,
    required this.eventId,
    this.width,
    this.height,
  });
  final String eventId;
  final double? width;
  final double? height;
  @override
  State<ScoreBoardIframe> createState() => _ScoreBoardIframeState();
}

class _ScoreBoardIframeState extends State<ScoreBoardIframe> {
  late final String _viewType;
  late final html.IFrameElement _iframeElement;
  double? _iframeHeight;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _iframeHeight = widget.height ?? 200;
    _viewType = 'iframe-${widget.eventId.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _iframeElement = html.IFrameElement()
      ..style.border = '0'
      ..style.display = 'block'
      ..style.width = '100%'
      ..style.height = '100%';

    // Register the view factory once for this viewType
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _iframeElement);
    _messageSubscription = html.window.onMessage.listen(_handleIframeMessage);
    _loadPreviewContent();
  }

  @override
  void didUpdateWidget(covariant ScoreBoardIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId) {
      _loadPreviewContent();
    }
  }

  Future<void> _loadPreviewContent() async {
    try {
      final htmlTemplate = await rootBundle.loadString(AppHtmlTemplates.preview);
      final cssTemplate = await rootBundle.loadString('assets/htmlTemplates/theme.css');
      final htmlWithCss = htmlTemplate.replaceFirst(
        '<link rel="stylesheet" type="text/css" href="theme.css">',
        '<style>$cssTemplate</style>',
      );
      final injectedHtml = htmlWithCss
          .replaceFirst(
            'const matchIdParam = getQueryParam(\'matchid\');',
            'const matchIdParam = ${jsonEncode(widget.eventId)};',
          )
          .replaceFirst(
            'const passParam = getQueryParam(\'pass\');',
            'const passParam = "";',
          );
      _iframeElement.srcdoc = injectedHtml;
    } catch (e) {
      _iframeElement.srcdoc = '<html><body><div style="padding:16px;color:#111">Unable to load scoreboard.</div></body></html>';
    }
  }

  void _handleIframeMessage(html.MessageEvent event) {
    if (_isDisposed) return;
    try {
      final data = event.data;
      dynamic payload;
      if (data is String) {
        payload = jsonDecode(data);
      } else if (data is Map) {
        payload = data;
      } else {
        try {
          final dynamic type = (data as dynamic)['type'];
          if (type != 'scoreboard_height') return;
          final dynamic height = (data as dynamic)['height'];
          if (height is num) {
            final newHeight = height.toDouble();
            if (mounted && newHeight > 0 && newHeight != _iframeHeight) {
              setState(() {
                _iframeHeight = newHeight;
              });
            }
          }
        } catch (_) {
          return;
        }
        return;
      }

      if (payload is Map && payload['type'] == 'scoreboard_height') {
        final height = payload['height'];
        if (height is num) {
          final newHeight = height.toDouble();
          if (mounted && newHeight > 0 && newHeight != _iframeHeight) {
            setState(() {
              _iframeHeight = newHeight;
            });
          }
        }
      }
    } catch (e, stack) {
      log('ScoreBoardIframe message parse error: $e', name: 'ScoreBoardIframe', error: e, stackTrace: stack);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _messageSubscription?.cancel();
    _messageSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Building ScoreBoardIframe with iframeHeight: $_iframeHeight');
    final Widget htmlView = HtmlElementView(viewType: _viewType);
    return LayoutBuilder(builder: (context, constraints) {
      final bool hasParentConstraint = constraints.maxWidth.isFinite || constraints.maxHeight.isFinite;
      if (hasParentConstraint) {
        return SizedBox(
          width: widget.width ?? (constraints.maxWidth == double.infinity ? null : constraints.maxWidth),
          height: _iframeHeight ?? (constraints.maxHeight == double.infinity ? null : constraints.maxHeight),
          child: htmlView,
        );
      }
      return SizedBox(
        width: widget.width,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: htmlView,
        ),
      );
    });
  }
}
