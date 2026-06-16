import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

Future<void> openUrl(String url) async {
  if (kIsWeb) {
    _openWebUrl(url);
    return;
  }

  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Could not launch $url');
  }
}

void _openWebUrl(String url) {
  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..rel = 'noopener noreferrer'
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

dynamic openUrlInNewTab() {
  if (!kIsWeb) return null;
  final newWindow = html.window.open('about:blank', '_blank');
  if (newWindow.toString().isEmpty) {
    final tempAnchor = html.AnchorElement(href: 'about:blank')
      ..target = '_blank'
      ..rel = 'noopener noreferrer'
      ..style.display = 'none';
    html.document.body?.append(tempAnchor);
    tempAnchor.click();
    tempAnchor.remove();
  }
  return newWindow;
}

Future<void> openUrlInWindow(dynamic windowHandle, String url) async {
  if (kIsWeb) {
    if (windowHandle != null) {
      try {
        windowHandle.location.href = url;
        return;
      } catch (_) {
        log('Failed to update opened window, falling back to anchor open: $url');
      }
    }
    _openWebUrl(url);
    return;
  }

  await openUrl(url);
}
