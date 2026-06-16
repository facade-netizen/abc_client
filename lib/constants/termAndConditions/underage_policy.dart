import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class UnderagePolicyPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UnderagePolicyPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'underagePolicy', options);
    if (popup != null) {
      final htmlContent = _buildUnderagePolicyHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildUnderagePolicyHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>Underage Gaming Policy</title>');
    buffer.writeln('<style>');
    buffer.writeln(
        'body{margin:0;padding:0;background:#F3F4F6;color:#111111;font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif;}');
    buffer.writeln('.wrapper{max-width:980px;margin:24px auto;padding:0 20px;}');
    buffer.writeln('.card{background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 16px 40px rgba(15,23,42,.08);border:1px solid rgba(15,23,42,.08);}');
    buffer.writeln('.header{display:flex;align-items:center;padding:24px 24px 0;}');
    buffer.writeln('.mark{width:6px;height:36px;background:#FBBF24;border-radius:999px;margin-right:14px;box-shadow:0 0 0 4px rgba(251,191,36,.12);}');
    buffer.writeln('.header h1{margin:0;font-size:32px;font-weight:800;letter-spacing:-.02em;color:#111827;}');
    buffer.writeln('.content{padding:0 24px 28px;}');
    buffer.writeln('h2{font-size:22px;font-weight:800;margin:0 0 18px;color:#111827;line-height:1.2;}');
    buffer.writeln('h3{font-size:18px;font-weight:800;margin:28px 0 14px;color:#111827;line-height:1.25;}');
    buffer.writeln('p{margin:0 0 16px;font-size:15px;line-height:1.75;color:#374151;}');
    buffer.writeln('ul{margin:0 0 16px 20px;padding:0;color:#374151;}');
    buffer.writeln('li{margin-bottom:12px;font-size:15px;line-height:1.75;}');
    buffer.writeln('</style>');
    buffer.writeln('</head><body>');
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>Underage Gaming Policy</h1></div><div class="content">');
    buffer.writeln(
        '<p>It is illegal for anyone under the age of 18 to open an account or gamble with https://www.6Ball.com/ (hereinafter "6Ball.com"). We strictly prohibit minors from registering or gambling, and we require new members to declare that they are over 18 years of age.</p>');
    buffer.writeln(
        '<p>6Ball.com takes all reasonable steps to prevent underage gamblers from accessing and using our services, including the use of identity verification services to ensure that all users are eligible to play. As a registered user, you can help us prevent underage gambling online.</p>');
    buffer.writeln(
        '<p>Especially if you access your 6Ball.com account on a shared computer, or if you have underage individuals in your household, it\'s important that you take precautions to prevent underage gambling. Do not use software that saves your username and password on shared devices, and consider installing parental control programs that can help prevent minors from accessing online gambling websites.</p>');
    buffer.writeln(
        '<p>6Ball.com includes several mechanisms that can help you detect unauthorized use of your player account. Note the last login time and IP address when you log into your account, and review your game transactions and financial transactions in your account details to ensure that there is no suspicious activity.</p>');
    buffer.writeln('<p>Parents with immediate concerns about underage gambling should report immediately to either email support@6Ball.com or the support chat.</p>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class UnderagePolicyPage extends StatelessWidget {
  const UnderagePolicyPage({super.key});

  static const _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111111),
    letterSpacing: 0.3,
  );

  static const _headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111111),
    letterSpacing: 0.6,
  );

  static const _bodyStyle = TextStyle(
    fontSize: 15,
    height: 1.75,
    color: Color(0xFF2C2C2C),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underage Gaming Policy'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF7F7F7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Underage Gaming Policy', style: _headingStyle),
                  const SizedBox(height: 18),
                  const Text(
                    'It is illegal for anyone under the age of 18 to open an account or gamble with https://www.6Ball.com/ (hereinafter "6Ball.com"). We strictly prohibit minors from registering or gambling, and we require new members to declare that they are over 18 years of age.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com takes all reasonable steps to prevent underage gamblers from accessing and using our services, including the use of identity verification services to ensure that all users are eligible to play. As a registered user, you can help us prevent underage gambling online.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Protect your account', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Especially if you access your 6Ball.com account on a shared computer, or if you have underage individuals in your household, it\'s important that you take precautions to prevent underage gambling. Do not use software that saves your username and password on shared devices, and consider installing parental control programs that can help prevent minors from accessing online gambling websites.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com includes several mechanisms that can help you detect unauthorized use of your player account. Note the last login time and IP address when you log into your account, and review your game transactions and financial transactions in your account details to ensure that there is no suspicious activity.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Parents with immediate concerns about underage gambling should report immediately to either email support@6Ball.com or the support chat.',
                    style: _bodyStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
