import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PrivacyPolicyPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'privacyPolicy', options);
    if (popup != null) {
      final htmlContent = _buildPrivacyHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildPrivacyHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>Privacy Policy</title>');
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
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>Privacy Policy</h1></div><div class="content">');
    buffer.writeln(
        '<p>Your privacy is important to us, and we are committed to protecting your personal information. We will be clear and open about why we collect your personal information and how we use it. Where you have choices or rights, we will explain these to you.</p>');
    buffer.writeln('<p>This Privacy Policy explains how 6Ball.com uses your personal information when you are using one of our website.</p>');
    buffer.writeln(
        '<p>If you do not agree with any statements contained within this Privacy Policy, please do not proceed any further on our website. Please be aware that registering an account on our website, placing bets and transferring funds will be deemed confirmation of your full agreement with our Terms and Conditions and our Privacy Policy. You have the right to cease using the website at any time; however, we may still be legally required to retain some of your personal information.</p>');
    buffer.writeln(
        '<p>We may periodically make changes to this Privacy Policy and will notify you of these changes by posting the modified terms on our platforms. We recommend that you revisit this Privacy Policy regularly.</p>');
    buffer.writeln('<h3>Who is in control of your information?</h3>');
    buffer.writeln(
        '<p>Throughout this Privacy Policy, "6Ball.com", "we", "our" and "us" relates to 6Ball, a limited liability company, registered in Curacao with company number 133567, having its registered address at Abraham de Veerstraat 9, Curacao. We control the ways your Personal Data is collected and the purposes for which your Personal Data is used by 6Ball.com, acting as the “data controller” for the purposes of applicable European data protection legislation.</p>');
    buffer.writeln('<h3>Our Data Protection Officer</h3>');
    buffer.writeln(
        '<p>If you have concerns or would like any further information about how 6Ball.com handles your personal information, you can contact our Data Protection Officer at support@6Ball.com.</p>');
    buffer.writeln('<h3>Information we collect about you</h3>');
    buffer.writeln('<h4>Personally identifiable information</h4>');
    buffer.writeln(
        '<p>You provide this information to us in the process of setting up an account, placing bets and using the services of the website. This information is required to give you access to certain parts of our website and related services. This data is collected when you:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>Register an account with 6Ball.com</li>');
    buffer.writeln('<li>voluntarily provide it when using the website</li>');
    buffer.writeln('<li>personally disclose the information in public areas of the website</li>');
    buffer.writeln('<li>Provide it when you contact our customer support team</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<p>The information includes your:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>Username</li>');
    buffer.writeln('<li>First and surname</li>');
    buffer.writeln('<li>Date of birth</li>');
    buffer.writeln('<li>Email address</li>');
    buffer.writeln('<li>Residential address</li>');
    buffer.writeln('<li>Phone number</li>');
    buffer.writeln('<li>Billing address</li>');
    buffer.writeln('<li>Identification documents</li>');
    buffer.writeln('<li>Proof of address documents</li>');
    buffer.writeln('<li>Transaction history</li>');
    buffer.writeln('<li>Website usage preferences</li>');
    buffer.writeln('<li>Any other information you provide us when using our platforms</li>');
    buffer.writeln('<li>Credit/debit card details, or other payment information</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>The information is also required for billing purposes and for the protection of minors. You can amend and update this information by contacting Customer Support. This data is for internal use only and is never passed to any third parties except those stated below.</p>');
    buffer.writeln('<h3>Telephone Calls</h3>');
    buffer.writeln(
        '<p>Telephone calls to and from our Customer Contact Centre are recorded for training and security purposes along with the resolution of any queries arising from the service you receive.</p>');
    buffer.writeln('<h3>Social Features of Our Products</h3>');
    buffer.writeln(
        '<p>If you choose to participate in any of the social features that we provide with our products (such as chat rooms) 6Ball.com may store record or otherwise process this data.</p>');
    buffer.writeln('<h3>Non-personally identifiable information and traffic analysis</h3>');
    buffer.writeln(
        '<p>6Ball.com strives to make our website as user friendly as possible and easy to find on the Internet. 6Ball.com collects data on how you use the site, which does not identify you personally. When you interact with the services, our servers keep an activity log unique to you that collects certain administrative and traffic information including: source IP address, time of access, date of access, web page(s) visited, language use, software crash reports and type of browser used. This information is essential for the provision and quality of our services.</p>');
    buffer.writeln('<h3>Cookies</h3>');
    buffer.writeln(
        '<p>6Ball.com uses cookies to ensure our website works efficiently and to enhance your visits to our platforms. Further information can be found in our Cookie Policy.</p>');
    buffer.writeln('<h3>How and why we use your personal information</h3>');
    buffer.writeln('<p>We use your personal information in a range of ways that fall into the following categories:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>To provide you with the products or services you have requested;</li>');
    buffer.writeln('<li>To meet our legal or regulatory obligations;</li>');
    buffer.writeln('<li>To monitor our website performance; and</li>');
    buffer.writeln('<li>To provide you with marketing information</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>Your rights over your personal information differ according to which category and lawful basis this fall into. This section provides more information about each category, the rights it gives you, and how to exercise these rights. These rights are in bold following each category.</p>');
    buffer.writeln('<h3>Providing our products and services</h3>');
    buffer.writeln(
        '<p>We use your personal information to enable you to use our websites, to set up your account, participate in the online sports book, casino and to provide you with customer service assistance.</p>');
    buffer.writeln(
        '<p>To provide our products and services, we share your information with external organisations working on our behalf. Further information can be found in the Sharing Information section.</p>');
    buffer.writeln(
        '<p>This category covers the essential activities required in order for us to provide you with the services you use or have signed up for. If you don’t want your information used in this way, your option is to not use our services and close your account.</p>');
    buffer.writeln(
        '<p>6Ball.com will use your identification document and/or proof of address to check your details in order for us to protect our users from fraudulent behaviour and to promote responsible gambling.</p>');
    buffer.writeln(
        '<p>We may conduct a security review at any time to validate the registration data provided by you and to verify your use of the services and your financial transactions for potential breach of our Terms and Conditions and of applicable law. Security reviews may include but are not limited to ordering a credit report and/or otherwise verifying the information you provide against third-party databases.</p>');
    buffer.writeln(
        '<p>We are required to carry out these activities to provide our products and services legally, responsibly, and in line with the requirements stipulated by regulators. We cannot provide you with our services without carrying out these activities, if you don’t want your information used in this way, your option is to not use our services and close your account.</p>');
    buffer.writeln('<h3>To monitor our website performance</h3>');
    buffer.writeln(
        '<p>As detailed above, we use cookies and traffic analysis in order to improve the performance of our website and services available. We have a legitimate interest in carrying out these activities and we ensure that we minimise any impact on your privacy.</p>');
    buffer.writeln(
        '<p>You have the ‘right to object’ to activities carried out for our legitimate interest if you believe your right to privacy outweighs our legitimate business interests. However, as the activities involved are central to our business, if you wish to object further than managing your cookies this may mean you need to close your account.</p>');
    buffer.writeln('<h3>Marketing</h3>');
    buffer.writeln(
        '<p>If you have given us your consent to do so, we will send you offers and promotions via email, SMS or online. We do not share your information with third parties for them to use for their own marketing.</p>');
    buffer.writeln('<h3>Your rights</h3>');
    buffer.writeln('<p><strong>Your rights to rectification</strong></p>');
    buffer.writeln(
        '<p>If you believe the personal information we hold on you is incorrect, you have the right for this to be rectified. For any information that cannot be updated through My Account, please contact support@6Ball.com.</p>');
    buffer.writeln('<p><strong>Your right to request a copy of your personal information</strong></p>');
    buffer.writeln(
        '<p>If you would like a copy of the personal information we hold about you, you should request it through live chat or by emailing support@6Ball.com and we will provide you with a form to complete. The form is not compulsory but helps us to provide you with the information you are looking for in a timely manner. To ensure the security of your personal information, we will ask you for valid proof of identity and once we’ve received it we will provide our response within one month. If your request is unusually complex and likely to take longer than a month, we will let you know as soon as we can and tell you how long we think it will take, such request may also incur an administration cost.</p>');
    buffer.writeln('<p><strong>Your right of erasure</strong></p>');
    buffer.writeln(
        '<p>You can request us to erase your personal data where there is no compelling reason to continue processing. This right only applies in certain circumstances; it is not a guaranteed or absolute right.</p>');
    buffer.writeln(
        '<p>The right to erasure does not apply if processing is necessary for one of the following reasons: to exercise the right of freedom of expression and information; to comply with a legal obligation; for the performance of a task carried out in the public interest or in the exercise of official authority; for archiving purposes in the public interest, scientific research historical research or statistical purposes where erasure is likely to render impossible or seriously impair the achievement of that processing; or for the establishment, exercise or defence of legal claims.</p>');
    buffer.writeln('<h3>Sharing your personal information</h3>');
    buffer.writeln('<p>We may disclose your Personal Data to third parties:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>if we are under a duty to disclose or share your personal information in order to comply with any legal or regulatory obligation;</li>');
    buffer.writeln('<li>in order to enforce or apply the terms of this notice or any other agreements;</li>');
    buffer.writeln('<li>to assist us in providing you with the products and services you request, including but not limited to third party software providers;</li>');
    buffer.writeln(
        '<li>if, in our sole determination, you are found to have cheated or attempted to defraud us, or other users of the service in any way including but not limited to game manipulation or payment fraud;</li>');
    buffer.writeln('<li>for the purpose of research on the prevention of addiction (this data will be made anonymous);</li>');
    buffer.writeln('<li>to protect the rights, property or safety of us, our customers or others; and</li>');
    buffer.writeln('<li>where we have received your permission for us to do so.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>Personal Information collected on the services may be stored and processed in any country in which we or our affiliates, suppliers or agents maintain facilities. By using our services, you expressly consent to any transfer of information outside of your country. When we transfer any part of your Personal Data outside of the EEA or adequate jurisdictions we will take reasonable steps to ensure that it is treated as securely as it is within the EEA or adequate jurisdictions. These steps include but are not limited to the following:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>Binding corporate rules;</li>');
    buffer.writeln('<li>Model contracts; or</li>');
    buffer.writeln('<li>US/EU privacy shield</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>Security</h3>');
    buffer.writeln(
        '<p>We understand the importance of security and the techniques needed to secure information. We store all of the Personal Information we receive directly from you in an encrypted and password protected database residing within our secure network behind active state-of-the-art firewall software. (Our Services support SSL Version 3 with 128-bit encryption). We also take measures to ensure our subsidiaries, agents, affiliates and suppliers employ adequate security measures.</p>');
    buffer.writeln('<h3>Retention</h3>');
    buffer.writeln(
        '<p>We retain personal information for as long as we reasonably require it for legal or business purposes. In determining data retention periods, 6Ball.com takes into consideration local laws, contractual obligations, and the expectations and requirements of our customers. When we no longer need your personal information, we securely delete or destroy it.</p>');
    buffer.writeln('<h3>Third-Party Practices</h3>');
    buffer.writeln(
        '<p>We cannot ensure the protection of any information that you provide to a third-party online site that links to or from the services or any information collected by any third party administering our affiliate program (if applicable) or any other program, since these third-party online sites are owned and operated independently from us. Any information collected by these third parties is governed by the privacy policy, if any, of such third party.</p>');
    buffer.writeln(
        '<p>Our web site may contain links to other web sites, which are outside our control and are not covered by this Privacy Policy. If you access other sites using the links provided, the operators of these sites may collect information from you which will be used by them in accordance with their privacy policy, which may differ from ours. We are not responsible solely the operators of these websites shall be responsible for their functionality or possible errors on the linked sites.</p>');
    buffer.writeln('<h3>Analytics</h3>');
    buffer.writeln('<p>The services contained in this section enable the Owner to monitor and analyse web traffic and can be used to keep track of user behaviour.</p>');
    buffer.writeln('<p><strong>Google Analytics (Google Inc.)</strong></p>');
    buffer.writeln(
        '<p>Google Analytics is a web analysis service provided by Google Inc. (“Google”). Google utilizes the Data collected to track and examine the use of 6Ball.com, to prepare reports on its activities and share them with other Google services.</p>');
    buffer.writeln('<p>Google may use the Data collected to contextualize and personalize the ads of its own advertising network.</p>');
    buffer.writeln('<p>Personal Data collected: Cookies and Usage Data</p>');
    buffer.writeln('<h3>Disclaimer</h3>');
    buffer.writeln(
        '<p>The Services operate ‘AS-IS’ and ‘AS-AVAILABLE’ without liability of any kind. We are not responsible for events beyond our direct control. Due to the complex and ever-changing nature of our technology and business, we cannot guarantee, nor do we claim that there will be error-free performance regarding the privacy of your Personal Information, and we will not be liable for any indirect, incidental, consequential or punitive damages relating to the use or release of said Personal Information.</p>');
    buffer.writeln('<h3>Changes to our Privacy Statement</h3>');
    buffer.writeln('<p>We may update this policy from time to time, so please review it frequently.</p>');
    buffer.writeln(
        '<p>If any material changes are made to this Privacy Policy we will use reasonable endeavours to inform you in advance by email, notice on the Website or other agreed communications channels. We will communicate the changes to you in advance, giving an appropriate amount of time for you to consider and understand the changes before they become effective.</p>');
    buffer.writeln(
        '<p>We will not enforce material changes to the Privacy Policy without your express consent. If you decline to accept the changes to the Privacy Policy, or otherwise do not accept the changes within the time period, we may not be able to continue to provide some or all products and services.</p>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111111),
    letterSpacing: 0.3,
  );

  static const _subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111111),
    letterSpacing: 0.3,
  );

  static const _bodyStyle = TextStyle(
    fontSize: 15,
    height: 1.75,
    color: Color(0xFF374151),
  );

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
        title: const Text('Privacy Policy'),
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
                  const Text('Privacy Policy', style: _titleStyle),
                  const SizedBox(height: 18),
                  const Text(
                    'Your privacy is important to us, and we are committed to protecting your personal information. We will be clear and open about why we collect your personal information and how we use it. Where you have choices or rights, we will explain these to you.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This Privacy Policy explains how 6Ball.com uses your personal information when you are using one of our website.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you do not agree with any statements contained within this Privacy Policy, please do not proceed any further on our website. Please be aware that registering an account on our website, placing bets and transferring funds will be deemed confirmation of your full agreement with our Terms and Conditions and our Privacy Policy. You have the right to cease using the website at any time; however, we may still be legally required to retain some of your personal information.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We may periodically make changes to this Privacy Policy and will notify you of these changes by posting the modified terms on our platforms. We recommend that you revisit this Privacy Policy regularly.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Who is in control of your information?', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'Throughout this Privacy Policy, "6Ball.com", "we", "our" and "us" relates to 6Ball, a limited liability company, registered in Curacao with company number 133567, having its registered address at Abraham de Veerstraat 9, Curacao. We control the ways your Personal Data is collected and the purposes for which your Personal Data is used by 6Ball.com, acting as the “data controller” for the purposes of applicable European data protection legislation.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Our Data Protection Officer', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'If you have concerns or would like any further information about how 6Ball.com handles your personal information, you can contact our Data Protection Officer at support@6Ball.com.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Information we collect about you', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text('Personally identifiable information', style: _bodyStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'You provide this information to us in the process of setting up an account, placing bets and using the services of the website. This information is required to give you access to certain parts of our website and related services. This data is collected when you:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  _buildBullet('Register an account with 6Ball.com'),
                  _buildBullet('voluntarily provide it when using the website'),
                  _buildBullet('personally disclose the information in public areas of the website'),
                  _buildBullet('Provide it when you contact our customer support team'),
                  const SizedBox(height: 12),
                  const Text('The information includes your:', style: _bodyStyle),
                  const SizedBox(height: 12),
                  _buildBullet('Username'),
                  _buildBullet('First and surname'),
                  _buildBullet('Date of birth'),
                  _buildBullet('Email address'),
                  _buildBullet('Residential address'),
                  _buildBullet('Phone number'),
                  _buildBullet('Billing address'),
                  _buildBullet('Identification documents'),
                  _buildBullet('Proof of address documents'),
                  _buildBullet('Transaction history'),
                  _buildBullet('Website usage preferences'),
                  _buildBullet('Any other information you provide us when using our platforms'),
                  _buildBullet('Credit/debit card details, or other payment information'),
                  const SizedBox(height: 12),
                  const Text(
                    'The information is also required for billing purposes and for the protection of minors. You can amend and update this information by contacting Customer Support. This data is for internal use only and is never passed to any third parties except those stated below.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Telephone Calls', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'Telephone calls to and from our Customer Contact Centre are recorded for training and security purposes along with the resolution of any queries arising from the service you receive.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Social Features of Our Products', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'If you choose to participate in any of the social features that we provide with our products (such as chat rooms) 6Ball.com may store record or otherwise process this data.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Non-personally identifiable information and traffic analysis', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com strives to make our website as user friendly as possible and easy to find on the Internet. 6Ball.com collects data on how you use the site, which does not identify you personally. When you interact with the services, our servers keep an activity log unique to you that collects certain administrative and traffic information including: source IP address, time of access, date of access, web page(s) visited, language use, software crash reports and type of browser used. This information is essential for the provision and quality of our services.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Cookies', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com uses cookies to ensure our website works efficiently and to enhance your visits to our platforms. Further information can be found in our Cookie Policy.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('How and why we use your personal information', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We use your personal information in a range of ways that fall into the following categories:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  _buildBullet('To provide you with the products or services you have requested;'),
                  _buildBullet('To meet our legal or regulatory obligations;'),
                  _buildBullet('To monitor our website performance; and'),
                  _buildBullet('To provide you with marketing information'),
                  const SizedBox(height: 12),
                  const Text(
                    'Your rights over your personal information differ according to which category and lawful basis this fall into. This section provides more information about each category, the rights it gives you, and how to exercise these rights. These rights are in bold following each category.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Providing our products and services', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We use your personal information to enable you to use our websites, to set up your account, participate in the online sports book, casino and to provide you with customer service assistance.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To provide our products and services, we share your information with external organisations working on our behalf. Further information can be found in the Sharing Information section.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This category covers the essential activities required in order for us to provide you with the services you use or have signed up for. If you don’t want your information used in this way, your option is to not use our services and close your account.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com will use your identification document and/or proof of address to check your details in order for us to protect our users from fraudulent behaviour and to promote responsible gambling.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We may conduct a security review at any time to validate the registration data provided by you and to verify your use of the services and your financial transactions for potential breach of our Terms and Conditions and of applicable law. Security reviews may include but are not limited to ordering a credit report and/or otherwise verifying the information you provide against third-party databases.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We are required to carry out these activities to provide our products and services legally, responsibly, and in line with the requirements stipulated by regulators. We cannot provide you with our services without carrying out these activities, if you don’t want your information used in this way, your option is to not use our services and close your account.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('To monitor our website performance', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'As detailed above, we use cookies and traffic analysis in order to improve the performance of our website and services available. We have a legitimate interest in carrying out these activities and we ensure that we minimise any impact on your privacy.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You have the ‘right to object’ to activities carried out for our legitimate interest if you believe your right to privacy outweighs our legitimate business interests. However, as the activities involved are central to our business, if you wish to object further than managing your cookies this may mean you need to close your account.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Marketing', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'If you have given us your consent to do so, we will send you offers and promotions via email, SMS or online. We do not share your information with third parties for them to use for their own marketing.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Your rights', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'Your rights to rectification',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you believe the personal information we hold on you is incorrect, you have the right for this to be rectified. For any information that cannot be updated through My Account, please contact support@6Ball.com.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your right to request a copy of your personal information',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you would like a copy of the personal information we hold about you, you should request it through live chat or by emailing support@6Ball.com and we will provide you with a form to complete. The form is not compulsory but helps us to provide you with the information you are looking for in a timely manner. To ensure the security of your personal information, we will ask you for valid proof of identity and once we’ve received it we will provide our response within one month. If your request is unusually complex and likely to take longer than a month, we will let you know as soon as we can and tell you how long we think it will take, such request may also incur an administration cost.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your right of erasure',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You can request us to erase your personal data where there is no compelling reason to continue processing. This right only applies in certain circumstances; it is not a guaranteed or absolute right.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The right to erasure does not apply if processing is necessary for one of the following reasons: to exercise the right of freedom of expression and information; to comply with a legal obligation; for the performance of a task carried out in the public interest or in the exercise of official authority; for archiving purposes in the public interest, scientific research historical research or statistical purposes where erasure is likely to render impossible or seriously impair the achievement of that processing; or for the establishment, exercise or defence of legal claims.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Sharing your personal information', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We may disclose your Personal Data to third parties:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  _buildBullet('if we are under a duty to disclose or share your personal information in order to comply with any legal or regulatory obligation;'),
                  _buildBullet('in order to enforce or apply the terms of this notice or any other agreements;'),
                  _buildBullet('to assist us in providing you with the products and services you request, including but not limited to third party software providers;'),
                  _buildBullet(
                      'if, in our sole determination, you are found to have cheated or attempted to defraud us, or other users of the service in any way including but not limited to game manipulation or payment fraud;'),
                  _buildBullet('for the purpose of research on the prevention of addiction (this data will be made anonymous);'),
                  _buildBullet('to protect the rights, property or safety of us, our customers or others; and'),
                  _buildBullet('where we have received your permission for us to do so.'),
                  const SizedBox(height: 12),
                  const Text(
                    'Personal Information collected on the services may be stored and processed in any country in which we or our affiliates, suppliers or agents maintain facilities. By using our services, you expressly consent to any transfer of information outside of your country. When we transfer any part of your Personal Data outside of the EEA or adequate jurisdictions we will take reasonable steps to ensure that it is treated as securely as it is within the EEA or adequate jurisdictions. These steps include but are not limited to the following:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  _buildBullet('Binding corporate rules;'),
                  _buildBullet('Model contracts; or'),
                  _buildBullet('US/EU privacy shield'),
                  const SizedBox(height: 24),
                  const Text('Security', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We understand the importance of security and the techniques needed to secure information. We store all of the Personal Information we receive directly from you in an encrypted and password protected database residing within our secure network behind active state-of-the-art firewall software. (Our Services support SSL Version 3 with 128-bit encryption). We also take measures to ensure our subsidiaries, agents, affiliates and suppliers employ adequate security measures.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Retention', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We retain personal information for as long as we reasonably require it for legal or business purposes. In determining data retention periods, 6Ball.com takes into consideration local laws, contractual obligations, and the expectations and requirements of our customers. When we no longer need your personal information, we securely delete or destroy it.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Third-Party Practices', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We cannot ensure the protection of any information that you provide to a third-party online site that links to or from the services or any information collected by any third party administering our affiliate program (if applicable) or any other program, since these third-party online sites are owned and operated independently from us. Any information collected by these third parties is governed by the privacy policy, if any, of such third party.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Our web site may contain links to other web sites, which are outside our control and are not covered by this Privacy Policy. If you access other sites using the links provided, the operators of these sites may collect information from you which will be used by them in accordance with their privacy policy, which may differ from ours. We are not responsible solely the operators of these websites shall be responsible for their functionality or possible errors on the linked sites.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Analytics', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'The services contained in this section enable the Owner to monitor and analyse web traffic and can be used to keep track of user behaviour.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Google Analytics (Google Inc.)',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Google Analytics is a web analysis service provided by Google Inc. (“Google”). Google utilizes the Data collected to track and examine the use of 6Ball.com, to prepare reports on its activities and share them with other Google services.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Google may use the Data collected to contextualize and personalize the ads of its own advertising network.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Personal Data collected: Cookies and Usage Data',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Disclaimer', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'The Services operate ‘AS-IS’ and ‘AS-AVAILABLE’ without liability of any kind. We are not responsible for events beyond our direct control. Due to the complex and ever-changing nature of our technology and business, we cannot guarantee, nor do we claim that there will be error-free performance regarding the privacy of your Personal Information, and we will not be liable for any indirect, incidental, consequential or punitive damages relating to the use or release of said Personal Information.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Changes to our Privacy Statement', style: _subtitleStyle),
                  const SizedBox(height: 12),
                  const Text(
                    'We may update this policy from time to time, so please review it frequently.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If any material changes are made to this Privacy Policy we will use reasonable endeavours to inform you in advance by email, notice on the Website or other agreed communications channels. We will communicate the changes to you in advance, giving an appropriate amount of time for you to consider and understand the changes before they become effective.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We will not enforce material changes to the Privacy Policy without your express consent. If you decline to accept the changes to the Privacy Policy, or otherwise do not accept the changes within the time period, we may not be able to continue to provide some or all products and services.',
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
