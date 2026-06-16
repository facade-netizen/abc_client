import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;

import '../blocs/authBlocs/user_auth_change_bloc.dart';
import '../blocs/fetchBlocs/fetch_news_announcements_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/news_signalr_bloc.dart';
import '../models/news_announcement_model.dart';
import 'colors.dart';

class MarqueeNews extends StatefulWidget {
  final double velocity;

  const MarqueeNews({super.key, this.velocity = 80.0});

  @override
  State<MarqueeNews> createState() => _MarqueeNewsState();
}

class _MarqueeNewsState extends State<MarqueeNews> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _offset = 0;
  double? _contentWidth;
  Duration _lastElapsed = Duration.zero;
  final GlobalKey _contentKey = GlobalKey();
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_contentWidth == null || _contentWidth! <= 0) {
      _lastElapsed = elapsed;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureContent());
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.5) return; // skip large jumps (e.g. tab switch)
    setState(() {
      _offset += widget.velocity * dt;
      if (_offset >= _contentWidth!) {
        _offset -= _contentWidth!;
      }
    });
  }

  void _measureContent() {
    final ctx = _contentKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _contentWidth = box.size.width;
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _openAnnouncementsPopup(List<NewsAnnouncement> announcements) {
    final htmlContent = _buildAnnouncementHtml(announcements);
    final popup = web.window.open('', 'announcements', 'width=780,height=600,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no');
    if (popup != null) {
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  String _buildAnnouncementHtml(List<NewsAnnouncement> announcements) {
    final buffer = StringBuffer();
    final backgroundImageUrl = Uri.base.resolve('assets/images/bg-login.jpg').toString();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<title>Announcement</title>');
    buffer.writeln('<style>');
    buffer.writeln('''
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body {
        font-family: 'Segoe UI', Roboto, -apple-system, BlinkMacSystemFont, sans-serif;
        background:
          linear-gradient(rgba(0, 0, 0, 0.12), rgba(0, 0, 0, 0.18)),
          url('$backgroundImageUrl') center center / cover no-repeat fixed;
        min-height: 100vh;
        padding: 40px 40px 28px;
      }
      .card {
        background: #fff;
        border-radius: 2px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.28);
        overflow: hidden;
        max-width: 668px;
        margin: 0 auto;
      }
      .header {
        background: linear-gradient(to bottom, #3a3a3a, #000000);
        padding: 11px 18px;
        border-bottom: 1px solid #cfd6da;
      }
      .header h1 {
        font-size: 17px;
        font-weight: 700;
        color: #ffbf1a;
        font-style: normal;
      }
      .list { padding: 0; background: #fff; }
      .item {
        display: flex;
        align-items: flex-start;
        padding: 16px 22px;
        border-bottom: 1px solid #e0e0e0;
      }
      .item:last-child { border-bottom: none; }
      .date-col {
        width: 55px;
        flex-shrink: 0;
        text-align: center;
        padding-top: 4px;
        border-top: 2px solid #888;
        margin-right: 16px;
      }
      .date-day {
        font-size: 26px;
        font-weight: bold;
        color: #222;
        line-height: 1.15;
      }
      .date-rest {
        font-size: 11px;
        color: #999;
        line-height: 1.4;
      }
      .msg {
        flex: 1;
        font-size: 13px;
        line-height: 1.65;
        color: #333;
        padding-top: 2px;
      }
      .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 5px;
        padding: 12px;
        border-top: 1px solid #e0e0e0;
        background: #fafafa;
      }
      .page-btn {
        padding: 3px 12px;
        border: 1px solid #bbb;
        background: #f0f0f0;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
        color: #555;
      }
      .page-btn:hover { background: #e0e0e0; }
      .page-active {
        display: inline-block;
        background: #555;
        color: #ffbf1a;
        border-radius: 3px;
        border: none;
        padding: 3px 9px;
        font-weight: bold;
        font-size: 12px;
      }
    ''');
    buffer.writeln('</style></head><body>');
    buffer.writeln('<div class="card">');
    buffer.writeln('<div class="header"><h1>Announcement</h1></div>');
    buffer.writeln('<div class="list">');
    for (final item in announcements) {
      final parts = item.title.split(' ');
      final day = parts.isNotEmpty ? parts[0] : '';
      final month = parts.length > 1 ? parts[1] : '';
      final year = parts.length > 2 ? parts[2] : '';
      final escapedMsg = item.description.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
      buffer.writeln('<div class="item">');
      buffer.writeln('  <div class="date-col"><div class="date-day">$day</div><div class="date-rest">$month</div><div class="date-rest">$year</div></div>');
      buffer.writeln('  <div class="msg">$escapedMsg</div>');
      buffer.writeln('</div>');
    }
    buffer.writeln('</div>');
    buffer.writeln('<div class="pagination"><button class="page-btn">Prev</button><span class="page-active">1</span><button class="page-btn">Next</button></div>');
    buffer.writeln('</div>');
    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  List<Widget> _buildNewsWidgets(List<NewsAnnouncement> items) {
    final List<Widget> widgets = [];
    for (final item in items) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: const Color(0xFFAAD4FF), borderRadius: BorderRadius.circular(4)),
          child: Text(
            item.title,
            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
        ),
      );
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Text(
            item.description,
            style: TextStyle(
              color: const Color(0xFFAAD4FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: const Color(0xFFAAD4FF),
            ),
            maxLines: 1,
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        final isLoggedIn = ucs is UserAuthChangesSuccess && ucs.savedUserAuth != null;
        return Visibility(
          visible: isLoggedIn,
          child: BlocBuilder<FetchNewsAnnouncementsBloc, FetchNewsAnnouncementsState>(
            builder: (context, state) {
              final List<NewsAnnouncement> announcements = state is FetchNewsAnnouncementsSuccess ? state.announcements : [];
              return BlocBuilder<NewsSRBloc, NewsSRState>(
                builder: (context, state) {
                  if (state is NewsSRSuccess) {
                    final srNewsIds = state.newsList.map((e) => e.newsId).toSet();
                    final mergedNews = [
                      ...state.newsList,
                      ...announcements.where((a) => !srNewsIds.contains(a.newsId)),
                    ];
                    final filtered = mergedNews.where((a) => a.isDeleted != true).toList();
                    final Map<dynamic, NewsAnnouncement> uniqueById = {};
                    for (final item in filtered) {
                      uniqueById.putIfAbsent(item.newsId, () => item);
                    }
                    announcements
                      ..clear()
                      ..addAll(uniqueById.values);
                  }
                  return MouseRegion(
                    cursor: announcements.isNotEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: GestureDetector(
                      onTap: announcements.isNotEmpty ? () => _openAnnouncementsPopup(announcements) : null,
                      child: Container(
                        height: 25,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(gradient: marqueeGradient, borderRadius: BorderRadius.circular(4)),
                        child: Stack(
                          children: [
                            if (announcements.isNotEmpty)
                              Positioned.fill(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) => _measureContent());
                                    return ClipRect(
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: -_offset,
                                            top: 2.25,
                                            child: Row(key: _contentKey, children: _buildNewsWidgets(announcements)),
                                          ),
                                          if (_contentWidth != null)
                                            Positioned(
                                              left: _contentWidth! - _offset,
                                              top: 2.25,
                                              child: Row(children: _buildNewsWidgets(announcements)),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: ClipPath(
                                clipper: _NewsArrowClipper(),
                                child: Container(
                                  height: 25,
                                  padding: const EdgeInsets.only(left: 8, right: 16),
                                  color: const Color(0xFF3a4e58),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.mic, size: 16, color: white),
                                      SizedBox(width: 4),
                                      Text(
                                        "News",
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NewsArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final arrowWidth = 10.0;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowWidth, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
