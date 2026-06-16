import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class KycPolicyPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const KycPolicyPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'kycPolicy', options);
    if (popup != null) {
      final htmlContent = _buildKycHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildKycHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>KYC Policy</title>');
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
    buffer.writeln('.note{margin:0 0 16px;padding:16px 18px;background:#F8FAFC;border-left:4px solid #CBD5E1;border-radius:8px;font-size:14px;line-height:1.75;color:#475569;}');
    buffer.writeln('</style>');
    buffer.writeln('</head><body>');
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>KYC</h1></div><div class="content">');
    buffer.writeln('<h2>KNOW YOUR CUSTOMER POLICY</h2>');
    buffer.writeln('<p>To maintain the highest level of security, we require all our members to provide us with certain documentation in order to validate their accounts.</p>');
    buffer.writeln('<p>Please note that the identification procedures shall be done before a cardholder starts operating and using services of our merchants.</p>');
    buffer.writeln('<h3>Why do I need to provide documentation?</h3>');
    buffer.writeln('<p>There are several reasons:</p>');
    buffer.writeln('<ul>');
    buffer.writeln(
        '<li>We are committed to providing a socially responsible platform for online gaming. All of our members must be 18 or older and we are bound by our licensing agreement to verify this.</li>');
    buffer.writeln('<li>Secondly, as a respected online and global company it is in our interests to guarantee maximum security on all transactions.</li>');
    buffer.writeln(
        '<li>Thirdly, our payment processors require that our policies are in line with international banking standards. A proven business relationship with each and every member is mandatory for the protection of all parties. Our licensing agreement also obliges us to comply with this.</li>');
    buffer.writeln(
        '<li>Finally, by ensuring that your account details are absolutely correct, the inconvenience of “missing payments” can be avoided. It can take weeks (and sometimes months) to trace, recall and resend using the correct information. This lengthy process also results in additional fees from our processors.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>WHAT DOCUMENTS DO I NEED TO PROVIDE?</h3>');
    buffer.writeln('<p><strong>PROOF OF ID:</strong></p>');
    buffer.writeln('<p>A color copy of a valid government issued form of ID (Driver’s License, Passport, State ID or Military ID)</p>');
    buffer.writeln('<p><strong>PROOF OF ADDRESS:</strong></p>');
    buffer.writeln('<p>A copy of a recent utility bill showing your address</p>');
    buffer.writeln('<div class="note">Note: If your government Id shows your address, you do not need to provide further proof of address.</div>');
    buffer.writeln('<p>Additional documentation might be required depending on the withdrawal method you choose.</p>');
    buffer.writeln('<h3>When do I need to provide these documents?</h3>');
    buffer.writeln(
        '<p>We greatly appreciate your cooperation in providing these at your earliest possible convenience to avoid any delays in processing your transactions. We must be in receipt of the documents before any cash transactions can be sent back to you. Under special circumstances we may require the documents before further activity (deposits and wagering) can take place on your account.</p>');
    buffer.writeln(
        '<p>Please understand, if we do not have the required documents on file, your pending withdrawals will be cancelled and credited back to your account. You will be notified when this happens via the notification system.</p>');
    buffer.writeln('<h3>How can I send you these documents?</h3>');
    buffer.writeln('<p>Please scan your documents, or take a high quality digital camera picture, save the images as jpegs, then upload the files using our secure form.</p>');
    buffer.writeln('<h3>How do I know my documents are safe with you?</h3>');
    buffer.writeln(
        '<p>The security of your documentation is of paramount importance. All files are protected with the highest level of encryption at every step of the review process. All documentation received is treated with the utmost respect and confidentiality.</p>');
    buffer.writeln(
        '<p>We’d like to thank you for your cooperation in helping us make 6Ball.com a safer place to play. As always, if you have any questions about this policy, or anything else, don’t hesitate to contact us using the contact us links on this page.</p>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class KycPolicyPage extends StatelessWidget {
  const KycPolicyPage({super.key});

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
    height: 1.65,
    color: Color(0xFF2C2C2C),
  );

  static const _labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Color(0xFF111111),
  );

  static const _noteStyle = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: Color(0xFF444444),
    fontStyle: FontStyle.italic,
  );

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: _bodyStyle),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC'),
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
                  const Text('KNOW YOUR CUSTOMER POLICY', style: _headingStyle),
                  const SizedBox(height: 18),
                  const Text(
                    'To maintain the highest level of security, we require all our members to provide us with certain documentation in order to validate their accounts.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please note that the identification procedures shall be done before a cardholder starts operating and using services of our merchants.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 26),
                  const Text('Why do I need to provide documentation?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text('There are several reasons:', style: _bodyStyle),
                  const SizedBox(height: 16),
                  _buildBullet(
                    'We are committed to providing a socially responsible platform for online gaming. All of our members must be 18 or older and we are bound by our licensing agreement to verify this.',
                  ),
                  _buildBullet(
                    'Secondly, as a respected online and global company it is in our interests to guarantee maximum security on all transactions.',
                  ),
                  _buildBullet(
                    'Thirdly, our payment processors require that our policies are in line with international banking standards. A proven business relationship with each and every member is mandatory for the protection of all parties. Our licensing agreement also obliges us to comply with this.',
                  ),
                  _buildBullet(
                    'Finally, by ensuring that your account details are absolutely correct, the inconvenience of “missing payments” can be avoided. It can take weeks (and sometimes months) to trace, recall and resend using the correct information. This lengthy process also results in additional fees from our processors.',
                  ),
                  const SizedBox(height: 24),
                  const Text('WHAT DOCUMENTS DO I NEED TO PROVIDE?', style: _sectionTitleStyle),
                  const SizedBox(height: 18),
                  const Text('PROOF OF ID:', style: _labelStyle),
                  const SizedBox(height: 8),
                  const Text(
                    'A color copy of a valid government issued form of ID (Driver’s License, Passport, State ID or Military ID)',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 16),
                  const Text('PROOF OF ADDRESS:', style: _labelStyle),
                  const SizedBox(height: 8),
                  const Text(
                    'A copy of a recent utility bill showing your address',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Note: If your government Id shows your address, you do not need to provide further proof of address.',
                    style: _noteStyle,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Additional documentation might be required depending on the withdrawal method you choose.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('When do I need to provide these documents?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'We greatly appreciate your cooperation in providing these at your earliest possible convenience to avoid any delays in processing your transactions. We must be in receipt of the documents before any cash transactions can be sent back to you. Under special circumstances we may require the documents before further activity (deposits and wagering) can take place on your account.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please understand, if we do not have the required documents on file, your pending withdrawals will be cancelled and credited back to your account. You will be notified when this happens via the notification system.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('How can I send you these documents?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Please scan your documents, or take a high quality digital camera picture, save the images as jpegs, then upload the files using our secure form.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('How do I know my documents are safe with you?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'The security of your documentation is of paramount importance. All files are protected with the highest level of encryption at every step of the review process. All documentation received is treated with the utmost respect and confidentiality.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'We’d like to thank you for your cooperation in helping us make 6Ball.com a safer place to play. As always, if you have any questions about this policy, or anything else, don’t hesitate to contact us using the contact us links on this page.',
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
