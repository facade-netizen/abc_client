import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../../../constants/app_string_constants.dart';
import '../../../reusables/buttons.dart';

class AppDownloadPopup {
  static const String _qrCodeUrl = AppStringConstants.apkDownloadLinkQr;
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      final url = Uri.parse(html.window.location.origin).replace(path: '/download-app').toString();
      const options = 'width=450,height=350,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
      html.window.open(url, 'appDownload', options);
      return;
    }
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Download Android App',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => const _AppDownloadDialog(),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }
}

class AppDownloadPage extends StatelessWidget {
  const AppDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: const SafeArea(child: _AppDownloadContent()),
    );
  }
}

class _AppDownloadDialog extends StatelessWidget {
  const _AppDownloadDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.transparent, child: const _AppDownloadContent());
  }
}

class _AppDownloadContent extends StatelessWidget {
  const _AppDownloadContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 38,
                    decoration: BoxDecoration(color: const Color(0xFFFBBF24), borderRadius: BorderRadius.circular(999)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Scan to download Android APP',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.3),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: const Color.fromARGB(255, 182, 183, 185), thickness: 1),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color.fromARGB(255, 182, 183, 185)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              padding: const EdgeInsets.all(8),
              child: Image.network(AppDownloadPopup._qrCodeUrl, width: 180, height: 180, fit: BoxFit.cover),
            ),
            Divider(color: const Color.fromARGB(255, 182, 183, 185), thickness: 1),
            ColoredTextButton(
              height: 42,
              name: 'CLOSE',
              fontSize: 16,
              width: 242,
              onTap: () {
                html.window.close();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
