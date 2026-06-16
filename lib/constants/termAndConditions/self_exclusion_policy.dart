import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class SelfExclusionPolicyPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SelfExclusionPolicyPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'selfExclusionPolicy', options);
    if (popup != null) {
      final htmlContent = _buildSelfExclusionPolicyHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildSelfExclusionPolicyHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>Self-exclusion Policy</title>');
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
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>Self-exclusion Policy</h1></div><div class="content">');
    buffer.writeln(
        '<p>If you feel you are at risk of developing a gambling problem or believe you currently have a gambling problem, please consider using Self-Exclusion which prevents you gambling with 6Ball.com for a specified period of 6 months, 1 year, 2 years, 5 years or permanently.</p>');
    buffer.writeln('<p>If you want to stop playing for other reasons, please consider a Time-Out or using Account Closure.</p>');
    buffer.writeln('<h3>What happens when you self-exclude?</h3>');
    buffer.writeln(
        '<p>During a period of Self-Exclusion you will not be able to use your account for betting, although you will still be able to login and withdraw any remaining balance. It will not be possible to re-open your account for any reason, and 6Ball.com will do all it can to detect and close any new accounts you may open.</p>');
    buffer.writeln('<h3>Next steps</h3>');
    buffer.writeln(
        '<p>Whilst we will remove you from our marketing databases, we also suggest that you remove 6Ball.com from your notifications and delete/uninstall all 6Ball.com apps, downloads and social media links. You may also wish to consider installing software that blocks access to gambling websites.</p>');
    buffer.writeln('<p>We recommend that you seek support from a problem gambling support service to help you deal with your problem.</p>');
    buffer.writeln('<p>You can self-exclude your account in the My Gambling Controls section of Members by choosing Self-Exclusion.</p>');
    buffer.writeln('<p>Alternatively you can contact our customer care team for assistance and further information.</p>');
    buffer.writeln('<h3>Self-Exclusion Notice</h3>');
    buffer
        .writeln('<p>Should you opt to self-exclude from 6Ball.com, we strongly recommend that you seek exclusion from all other gambling operators you have an account with.</p>');
    buffer.writeln(
        '<p>You can self-exclude by contacting other gambling operators directly or you can exclude from other licensed operators by completing a Self-Exclusion Notice form.</p>');
    buffer.writeln('<p>Once completed the Self-Exclusion Notice form should be submitted to the nominated site, sports bookmaker or betting exchange operator.</p>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class SelfExclusionPolicyPage extends StatelessWidget {
  const SelfExclusionPolicyPage({super.key});

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
        title: const Text('Self-exclusion Policy'),
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
                  const Text('Self-exclusion Policy', style: _headingStyle),
                  const SizedBox(height: 18),
                  const Text(
                    'If you feel you are at risk of developing a gambling problem or believe you currently have a gambling problem, please consider using Self-Exclusion which prevents you gambling with 6Ball.com for a specified period of 6 months, 1 year, 2 years, 5 years or permanently.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you want to stop playing for other reasons, please consider a Time-Out or using Account Closure.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('What happens when you self-exclude?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'During a period of Self-Exclusion you will not be able to use your account for betting, although you will still be able to login and withdraw any remaining balance. It will not be possible to re-open your account for any reason, and 6Ball.com will do all it can to detect and close any new accounts you may open.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Next steps', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Whilst we will remove you from our marketing databases, we also suggest that you remove 6Ball.com from your notifications and delete/uninstall all 6Ball.com apps, downloads and social media links. You may also wish to consider installing software that blocks access to gambling websites.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We recommend that you seek support from a problem gambling support service to help you deal with your problem.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You can self-exclude your account in the My Gambling Controls section of Members by choosing Self-Exclusion.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alternatively you can contact our customer care team for assistance and further information.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Self-Exclusion Notice', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Should you opt to self-exclude from 6Ball.com, we strongly recommend that you seek exclusion from all other gambling operators you have an account with.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You can self-exclude by contacting other gambling operators directly or you can exclude from other licensed operators by completing a Self-Exclusion Notice form.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Once completed the Self-Exclusion Notice form should be submitted to the nominated site, sports bookmaker or betting exchange operator.',
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
