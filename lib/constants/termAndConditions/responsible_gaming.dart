import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ResponsibleGamingPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ResponsibleGamingPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'responsibleGaming', options);
    if (popup != null) {
      final htmlContent = _buildResponsibleGamingHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildResponsibleGamingHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>Responsible Gaming</title>');
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
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>Responsible Gaming</h1></div><div class="content">');
    buffer.writeln(
        '<p>6Ball.com is committed to endorsing responsible wagering among its customers as well as promoting the awareness of problem gambling and improving prevention, intervention and treatment.</p>');
    buffer.writeln(
        '<p>6Ball.com’s Responsible Gambling Policy sets out its commitment to minimizing the negative effects of problem gambling and to promoting responsible gambling practices.</p>');
    buffer.writeln(
        '<p>6Ball.com supports the generation of online gamblers offering them a wide range of games and entertainment. We also take responsibility for our product line-up.</p>');
    buffer.writeln(
        '<p>The aim of 6Ball.com is to provide the world’s safest and most innovative gaming platform for adults. The offered clear and safe products allow each user to play within his financial means and to receive the highest quality service. Integrity, fairness and reliability are the guiding principles of 6Ball.com’s work. It is therefore clear that 6Ball.com should do its best to avoid and reduce the problems which can arise from participation in gambling, particularly in cases of immoderate playing. At the same time it is important to respect the rights of those who take part in games of chance to a reasonable extent as means of entertainment.</p>');
    buffer.writeln('<h3>Responsible Gaming Principles</h3>');
    buffer.writeln(
        '<p>Responsible Gaming at 6Ball.com is based on three fundamental principles: Security of the player, Security of the game and Protection against gaming addiction. Together with research institutes, associations and therapy institutions, we work on creation of a responsible, secure and reliable framework for online gaming.</p>');
    buffer.writeln('<h3>Player security</h3>');
    buffer.writeln(
        '<p>We take responsibility for the security of our players. Protection of the players is based on forbidding the attendance of minors from participation in games and the protection of privacy, which involves responsible processing of personal data and payments. Fairness and the random nature of the products offered are monitored closely by independent organizations. Marketing communication is also geared towards player protection: we promise only what players can receive in our transparent line.</p>');
    buffer.writeln('<h3>Protection against gaming addiction</h3>');
    buffer.writeln(
        '<p>The majority of users who make sports bets, casino bets and other gaming offers play in moderation for entertainment. Certain habits and behavior patterns which are considered normal and not causing any concern can develop into addiction for some people and cause problems. In the same way, bets on sports and gambling can lead to problems for a small group of customers.</p>');
    buffer.writeln(
        '<p>Clients with gaming addiction are prohibited from further participation in the gaming line-up. Subsequently the customers are provided with contacts of organizations where they can receive professional advice and support.</p>');
    buffer.writeln('<h3>Self-responsibility</h3>');
    buffer.writeln(
        '<p>The basic principle promoted by 6Ball.com is that the final decision and responsibility on whether to play or not, and how much money can be spent on the game should be assumed by the customer himself.</p>');
    buffer.writeln(
        '<p>Self-responsibility of the customer is therefore the most effective form of protection from addiction. 6Ball.com sees its responsibility in assisting the customers by providing transparent products, full information and keeping a clear line of conduct.</p>');
    buffer.writeln('<h3>Protection of minors</h3>');
    buffer.writeln(
        '<p>6Ball.com does not allow minors (persons under the age of 18) to participate in games and make bets. That’s why the confirmation of having reached the age of majority and the confirmation of date of birth are mandatory requirements during registration. 6Ball.com considers the issue of minors taking part in games and betting very seriously. In order to offer the best possible protection of minors, we also rely on the support of parents and caregivers. Please keep your data for account access in a safe place (user ID and password).</p>');
    buffer.writeln(
        '<p>Furthermore, we would recommend that you install filter software. This software will allow you to restrict the access to Internet resources inappropriate for children and teenagers.</p>');
    buffer.writeln('<h3>Responsibility towards problems</h3>');
    buffer.writeln(
        '<p>6Ball.com offers a variety of games and bets, which are forms of entertainment for the majority of customers. At the same time the company takes responsibility for its customers by providing support and tools for maintenance of a secure and entertaining environment taking into account the associated risks.</p>');
    buffer.writeln(
        '<p>The clients who have difficulty in assessing risks, recognizing their own limits or those who suffer from gambling addiction are not able to enjoy our product line-up responsibly and perceive it as a form of entertainment. 6Ball.com takes responsibility for such users by blocking their access to its products for their own protection.</p>');
    buffer.writeln('<h3>Get informed with the main issues</h3>');
    buffer.writeln(
        '<p>Most people play for pleasure. Moderate participation in games within their financial capacity is fully acceptable. However, for a small percentage of people gambling is not a form of entertainment, it is a challenge that must be considered seriously.</p>');
    buffer.writeln('<h3>What is problematic game behavior?</h3>');
    buffer.writeln(
        '<p>A problematic game behavior is considered to be such behavior, which interferes with life, work, financial position or health of a person or his family. Long participation in games is counter indicative to such person as it can lead to negative consequences.</p>');
    buffer.writeln(
        '<p>In 1980 the pathological game dependence has been officially recognized and enlisted in the list of psychological diseases of international classification system DSM-IV and ICD-10. It is defined as long, repeating and frequently amplifying inclination for game, despite existing negative personal and social circumstances, such as debt, rupture of family relations and delay of professional growth.</p>');
    buffer.writeln('<h3>When should behavior be considered dependence?</h3>');
    buffer.writeln(
        '<p>It is necessary to underline that the diagnoses of game dependence can be qualified only by experts. The material presented on this page will help you to estimate and define your own game behaviour.</p>');
    buffer.writeln(
        '<p>The special hazard of addictions that are not associated with any substance is that it is very difficult to define the line between pleasure and addiction. Nevertheless, there are some diagnostic signals that may point out the existing problems. In the presence of at least five of the following symptoms, the likelihood of severe dependence is high:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>The player is deeply involved in gambling; all his thoughts are only about the game.</li>');
    buffer.writeln('<li>Bet sum increases in course of time.</li>');
    buffer.writeln('<li>Attempts to quit or control participation in the games appear to be unsuccessful.</li>');
    buffer.writeln('<li>When limiting participation in gambling, a person experiences irritation and disappointment.</li>');
    buffer.writeln('<li>The game is a way to escape from problems or discomfort.</li>');
    buffer.writeln('<li>The player tries to win back the lost amount.</li>');
    buffer.writeln('<li>Lies about his playing behavior.</li>');
    buffer.writeln('<li>Commits illegal acts.</li>');
    buffer.writeln('<li>Spoils or breaks the relationship with family and colleagues.</li>');
    buffer.writeln('<li>Borrows to participate in the games.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>Rules for responsible games</h3>');
    buffer.writeln('<p>Following the rules placed below, you can enjoy the game without anxiety:</p>');
    buffer.writeln('<ol>');
    buffer.writeln('<li>Start playing only when you are calm and concentrated.</li>');
    buffer.writeln('<li>Take regular breaks.</li>');
    buffer.writeln('<li>Define for yourself beforehand the monthly amount you can spend on the game.</li>');
    buffer.writeln('<li>Once setting a maximum limit, do not further increase it.</li>');
    buffer.writeln('<li>Before you start playing, define the maximum amount of winning, after reaching which you should stop playing.</li>');
    buffer.writeln('<li>Define the amount you can afford to lose beforehand.</li>');
    buffer.writeln('<li>Do not start playing under alcohol or drug influence.</li>');
    buffer.writeln('<li>Do not start playing in a depressed state.</li>');
    buffer.writeln('</ol>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class ResponsibleGamingPage extends StatelessWidget {
  const ResponsibleGamingPage({super.key});

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
        title: const Text('Responsible Gaming'),
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
                  const Text('Responsible Gaming', style: _headingStyle),
                  const SizedBox(height: 18),
                  const Text(
                    '6Ball.com is committed to endorsing responsible wagering among its customers as well as promoting the awareness of problem gambling and improving prevention, intervention and treatment.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com’s Responsible Gambling Policy sets out its commitment to minimizing the negative effects of problem gambling and to promoting responsible gambling practices.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '6Ball.com supports the generation of online gamblers offering them a wide range of games and entertainment. We also take responsibility for our product line-up.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The aim of 6Ball.com is to provide the world’s safest and most innovative gaming platform for adults. The offered clear and safe products allow each user to play within his financial means and to receive the highest quality service.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Integrity, fairness and reliability are the guiding principles of 6Ball.com’s work. It is therefore clear that 6Ball.com should do its best to avoid and reduce the problems which can arise from participation in gambling, particularly in cases of immoderate playing. At the same time it is important to respect the rights of those who take part in games of chance to a reasonable extent as means of entertainment.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Responsible Gaming Principles', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Responsible Gaming at 6Ball.com is based on three fundamental principles: Security of the player, Security of the game and Protection against gaming addiction. Together with research institutes, associations and therapy institutions, we work on creation of a responsible, secure and reliable framework for online gaming.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Player security', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'We take responsibility for the security of our players. Protection of the players is based on forbidding the attendance of minors from participation in games and the protection of privacy, which involves responsible processing of personal data and payments. Fairness and the random nature of the products offered are monitored closely by independent organizations. Marketing communication is also geared towards player protection: we promise only what players can receive in our transparent line.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Protection against gaming addiction', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'The majority of users who make sports bets, casino bets and other gaming offers play in moderation for entertainment. Certain habits and behavior patterns which are considered normal and not causing any concern can develop into addiction for some people and cause problems. In the same way, bets on sports and gambling can lead to problems for a small group of customers.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Clients with gaming addiction are prohibited from further participation in the gaming line-up. Subsequently the customers are provided with contacts of organizations where they can receive professional advice and support.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Self-responsibility', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'The basic principle promoted by 6Ball.com is that the final decision and responsibility on whether to play or not, and how much money can be spent on the game should be assumed by the customer himself.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Self-responsibility of the customer is therefore the most effective form of protection from addiction. 6Ball.com sees its responsibility in assisting the customers by providing transparent products, full information and keeping a clear line of conduct.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Protection of minors', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    '6Ball.com does not allow minors (persons under the age of 18) to participate in games and make bets. That’s why the confirmation of having reached the age of majority and the confirmation of date of birth are mandatory requirements during registration. 6Ball.com considers the issue of minors taking part in games and betting very seriously. In order to offer the best possible protection of minors, we also rely on the support of parents and caregivers. Please keep your data for account access in a safe place (user ID and password).',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Furthermore, we would recommend that you install filter software. This software will allow you to restrict the access to Internet resources inappropriate for children and teenagers.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Responsibility towards problems', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    '6Ball.com offers a variety of games and bets, which are forms of entertainment for the majority of customers. At the same time the company takes responsibility for its customers by providing support and tools for maintenance of a secure and entertaining environment taking into account the associated risks.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The clients who have difficulty in assessing risks, recognizing their own limits or those who suffer from gambling addiction are not able to enjoy our product line-up responsibly and perceive it as a form of entertainment. 6Ball.com takes responsibility for such users by blocking their access to its products for their own protection.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('Get informed with the main issues', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Most people play for pleasure. Moderate participation in games within their financial capacity is fully acceptable. However, for a small percentage of people gambling is not a form of entertainment, it is a challenge that must be considered seriously.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('What is problematic game behavior?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'A problematic game behavior is considered to be such behavior, which interferes with life, work, financial position or health of a person or his family. Long participation in games is counter indicative to such person as it can lead to negative consequences.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'In 1980 the pathological game dependence has been officially recognized and enlisted in the list of psychological diseases of international classification system DSM-IV and ICD-10. It is defined as long, repeating and frequently amplifying inclination for game, despite existing negative personal and social circumstances, such as debt, rupture of family relations and delay of professional growth.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('When should behavior be considered dependence?', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'It is necessary to underline that the diagnoses of game dependence can be qualified only by experts. The material presented on this page will help you to estimate and define your own game behaviour.',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The special hazard of addictions that are not associated with any substance is that it is very difficult to define the line between pleasure and addiction. Nevertheless, there are some diagnostic signals that may point out the existing problems. In the presence of at least five of the following symptoms, the likelihood of severe dependence is high:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 16),
                  _buildBullet('The player is deeply involved in gambling; all his thoughts are only about the game.'),
                  _buildBullet('Bet sum increases in course of time.'),
                  _buildBullet('Attempts to quit or control participation in the games appear to be unsuccessful.'),
                  _buildBullet('When limiting participation in gambling, a person experiences irritation and disappointment.'),
                  _buildBullet('The game is a way to escape from problems or discomfort.'),
                  _buildBullet('The player tries to win back the lost amount.'),
                  _buildBullet('Lies about his playing behavior.'),
                  _buildBullet('Commits illegal acts.'),
                  _buildBullet('Spoils or breaks the relationship with family and colleagues.'),
                  _buildBullet('Borrows to participate in the games.'),
                  const SizedBox(height: 24),
                  const Text('Rules for responsible games', style: _sectionTitleStyle),
                  const SizedBox(height: 14),
                  const Text(
                    'Following the rules placed below, you can enjoy the game without anxiety:',
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 16),
                  _buildBullet('Start playing only when you are calm and concentrated.'),
                  _buildBullet('Take regular breaks.'),
                  _buildBullet('Define for yourself beforehand the monthly amount you can spend on the game.'),
                  _buildBullet('Once setting a maximum limit, do not further increase it.'),
                  _buildBullet('Before you start playing, define the maximum amount of winning, after reaching which you should stop playing.'),
                  _buildBullet('Define the amount you can afford to lose beforehand.'),
                  _buildBullet('Do not start playing under alcohol or drug influence.'),
                  _buildBullet('Do not start playing in a depressed state.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
