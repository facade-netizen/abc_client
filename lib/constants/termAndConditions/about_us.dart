import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AboutUsPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AboutUsPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'aboutUs', options);
    if (popup != null) {
      final htmlContent = _buildAboutUsHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildAboutUsHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>About Us</title>');
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
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>About Us</h1></div><div class="content">');
    buffer.writeln(
        '<p>6Ball is one of the upcoming providers for online gaming entertainment across Sports Betting, Online and Live Casino operating in the emerging and the regulated markets.</p>');
    buffer.writeln('<p>We aim to utilize the latest technologies to provide innovative and interactive gaming experiences in a secure environment.</p>');
    buffer.writeln(
        '<p>We have dedicated ourselves to offering our customers a seamless and thrilling gaming experience while you are on the go. We aim to provide an exceptional and fully customizable online betting experience.</p>');
    buffer.writeln('<p>We are innovative, ambitious and passionate about what we do. We do it in a credible and responsible way, always aiming for the top.</p>');
    buffer.writeln(
        '<p>We only operate in regulated markets where we hold the appropriate licenses. We take our responsibilities to customers and our other stakeholders seriously and place great emphasis on working to a ‘compliance first’ model across the business.</p>');
    buffer.writeln(
        '<p>Dedicated Customer Service Team: We are here for you every step of the way with dedicated customer service managers standing by to provide you with a 24/7 top notch customer care service, handling any issues quickly and efficiently.</p>');
    buffer.writeln(
        '<p>When customers bet on our site they can rest assured that they are getting a wide variety of betting options, up to date information and the best odds available.</p>');
    buffer.writeln('<p>Our customers also have peace of mind, knowing that when it’s time to collect, they are betting with a well-known reputable company.</p>');
    buffer.writeln(
        '<p>We have integrated best and secured payment methods on our site and a transaction process that is quick, easy enabling our players to cash out their winnings quickly and securely.</p>');
    buffer.writeln('<h3>Business Address</h3>');
    buffer.writeln('<p><strong>Name:</strong> 6Ball</p>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
        title: const Text('About Us'),
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
                  const Text('About Us', style: _headingStyle),
                  const SizedBox(height: 18),
                  const Text(
                    '6Ball is one of the upcoming providers for online gaming entertainment across Sports Betting, Online and Live Casino operating in the emerging and the regulated markets.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We aim to utilize the latest technologies to provide innovative and interactive gaming experiences in a secure environment.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We have dedicated ourselves to offering our customers a seamless and thrilling gaming experience while you are on the go. We aim to provide an exceptional and fully customizable online betting experience.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We are innovative, ambitious and passionate about what we do. We do it in a credible and responsible way, always aiming for the top.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We only operate in regulated markets where we hold the appropriate licenses. We take our responsibilities to customers and our other stakeholders seriously and place great emphasis on working to a ‘compliance first’ model across the business.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Customer Service', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Dedicated Customer Service Team: We are here for you every step of the way with dedicated customer service managers standing by to provide you with a 24/7 top notch customer care service, handling any issues quickly and efficiently.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Why choose 6Ball?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'When customers bet on our site they can rest assured that they are getting a wide variety of betting options, up to date information and the best odds available.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Our customers also have peace of mind, knowing that when it’s time to collect, they are betting with a well-known reputable company.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Payments and security', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'We have integrated best and secured payment methods on our site and a transaction process that is quick, easy enabling our players to cash out their winnings quickly and securely.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Business Address', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text('Name: 6Ball', style: _bodyStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
