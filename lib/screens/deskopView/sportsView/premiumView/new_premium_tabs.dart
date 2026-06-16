import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'dart:ui' if (dart.library.html) 'dart:ui_web' as ui;

import '../../../../blocs/fetchBlocs/fetch_premium_market_bloc.dart';
import '../../../../constants/app_string_constants.dart';
import '../../../../reusables/loader.dart';

class NewPremiumStreamer extends StatefulWidget {
  const NewPremiumStreamer({super.key, required this.eventId, required this.sid});
  final String eventId;
  final String sid;
  @override
  State<NewPremiumStreamer> createState() => _NewPremiumStreamerState();
}

class _NewPremiumStreamerState extends State<NewPremiumStreamer> {
  @override
  void initState() {
    final gameName = widget.sid == "4"
        ? "cricket"
        : widget.sid == "1"
        ? "soccer"
        : widget.sid == "2"
        ? "tennis"
        : '';
    Map<String, dynamic> fetchPremiumMap = {
      "eventId": widget.eventId.toString(),
      "gameName": gameName,
      "platformId": "web",
      "ip": ip.value.isEmpty ? "Blocked" : ip.value,
      "isp": isp.value.isEmpty ? "Blocked" : isp.value,
      "isPremium": false,
    };
    context.read<FetchPremiumBloc>().add(FetchPremium(fetchPremiumMap: fetchPremiumMap));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPremiumBloc, FetchPremiumState>(
      builder: (context, state) {
        return state is FetchPremiumProgress
            ? LoaderContainerWithMessage()
            : state is FetchPremiumSuccess
            ? NewPremiumTabs(url: state.url)
            : SizedBox.fromSize();
      },
    );
  }
}

class NewPremiumTabs extends StatefulWidget {
  const NewPremiumTabs({super.key, required this.url});
  final String url;

  @override
  State<NewPremiumTabs> createState() => _NewPremiumTabsState();
}

class _NewPremiumTabsState extends State<NewPremiumTabs> {
  late final String _viewType;
  late final html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'premium-iframe-${widget.url.hashCode}';
    _iframeElement = html.IFrameElement()..src = widget.url;

    _iframeElement.onWheel.listen((html.WheelEvent event) {
      event.preventDefault();
      html.window.scrollBy(0, event.deltaY.toInt());
    });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _iframeElement);
  }

  @override
  void didUpdateWidget(covariant NewPremiumTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _iframeElement.src = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SizedBox(
        height: 500,
        width: double.infinity,
        child: HtmlElementView(viewType: _viewType),
      );
    }
    return const Center(
      child: Text('Premium tabs web view is available only on web.', style: TextStyle(fontSize: 18, color: Colors.red)),
    );
  }
}
