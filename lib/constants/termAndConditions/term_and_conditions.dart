import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class TermsAndConditionsPopup {
  static Future<void> open(BuildContext context) async {
    if (kIsWeb) {
      _openWebPopup();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TermsAndConditionsPage()),
      );
    }
  }

  static void _openWebPopup() {
    const options = 'width=900,height=760,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no';
    final popup = web.window.open('', 'termsAndConditions', options);
    if (popup != null) {
      final htmlContent = _buildTermsHtml();
      popup.document.open();
      popup.document.write(htmlContent.toJS);
      popup.document.close();
    }
  }

  static String _buildTermsHtml() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html><html><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('<title>Terms & Conditions</title>');
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
    buffer.writeln('<div class="wrapper"><div class="card"><div class="header"><span class="mark"></span><h1>Terms & Conditions</h1></div><div class="content">');
    buffer.writeln('<p><strong>Description:</strong> Initial Terms and Conditions replacing general rules.</p>');
    buffer.writeln('<h3>Introduction</h3>');
    buffer.writeln(
        '<p>These terms and conditions and the documents referred and linked to below (the “Terms”) set out the basis upon which the website operated under the URL https://6ball.com/?cb=1776314963731 (the “Website”) and its related or connected services (collectively, the “Service”) will be provided to you.</p>');
    buffer.writeln(
        '<p>Please read these terms very carefully as they form a binding legal agreement between you - our customer (the “Customer”) - and us. By opening an account (the “Account”) and using the Service you agree to be bound by these terms, together with any amendment which may be published from time to time.</p>');
    buffer.writeln('<p>If anything is not clear to you please contact us using the contact details below.</p>');
    buffer.writeln('<p>The Service is supplied by 6Ball.</p>');
    buffer.writeln(
        '<p>Transactions and payment services are operated by 6Ball a limited liability company registered in Curacao, with company registration number 133567 and holding a license no. 365/JAZ Sub-License GLH- OCCHKTW0707072017.</p>');
    buffer.writeln(
        '<p>6Ball.com will only communicate with Customers by email to their registered email address (the “Registered Email Address”) as provided when opening your 6Ball account: Communication from 6Ball.com will be issued through the following: mail only: support@6Ball.com</p>');
    buffer.writeln('<h3>General Terms</h3>');
    buffer.writeln(
        '<p>We reserve the right to amend the terms (including to any documents referred and linked to below) at any time. When such amendment is not substantial, we may not provide you with prior notice. You will be notified in advance for material changes to the terms and may require you to re-confirm acceptance to the updated terms before the changes come into effect. If you object to any such changes, you must immediately stop using the service and the termination provisions below will apply. Continued use of the service indicates your agreement to be bound by such changes. Any bets not settled prior to the changed terms taking effect will be subject to the pre-existing terms.</p>');
    buffer.writeln(
        '<p>If at any time you are in any doubt about how to place bets or otherwise use the service you should refer back to these terms or contact our customer service department (Customer Service Department) at support@6Ball.com</p>');
    buffer.writeln('<h3>1. Your Obligations</h3>');
    buffer.writeln('<p>You agree that at all times when using the Service:</p>');
    buffer.writeln('<ul>');
    buffer.writeln(
        '<li>You are over 18 years of age (or over the age of majority as stipulated in the laws of the jurisdiction applicable to you) and can enter into a binding legal agreement with us.</li>');
    buffer.writeln(
        '<li>It is the User’s responsibility to check and enter this site only if the user is in a country where it is lawful to place bets on the service (if in doubt, you should seek local legal advice). It is your responsibility to ensure that your use of the service is legal.</li>');
    buffer.writeln('<li>When sending money to us you are authorised to do so e.g. you are the authorised user of the debit/credit card or other payment method you use.</li>');
    buffer.writeln(
        '<li>You will not, by participating in the Services and/or placing bets be placed in a position of actual, potential or perceived conflict of interest in any manner.</li>');
    buffer.writeln('<li>You have never failed to pay, or attempted to fail to pay a liability on a bet.</li>');
    buffer.writeln(
        '<li>You are acting solely on your own behalf as a private individual in a personal capacity and not on behalf of another party or for any commercial purposes.</li>');
    buffer
        .writeln('<li>By placing bets you may lose some or all of your money lodged with us in accordance with these terms and you will be fully responsible for that loss.</li>');
    buffer.writeln(
        '<li>You must use the service for legitimate betting purposes only and must not nor attempt to manipulate any market or element within the service in bad faith or in a manner that adversely affects the integrity of the Service or us.</li>');
    buffer.writeln(
        '<li>When placing bets on the service you must not use any information obtained in breach of any legislation in force in the country in which you were when the bet was placed.</li>');
    buffer.writeln(
        '<li>You must make all payments to us in good faith and not attempt to reverse a payment made or take any action which will cause such payment to be reversed by a third party in order to avoid a liability legitimately incurred.</li>');
    buffer.writeln('<li>You must otherwise generally act in good faith in relation to us of the service at all times and for all bets made through the service.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>2. Registration</h3>');
    buffer.writeln('<p>You agree that at all times when using the service:</p>');
    buffer.writeln('<ul>');
    buffer.writeln(
        '<li>In order to protect the integrity of the service and for other operational reasons we reserve the right to refuse to accept a registration application from any applicant at our sole discretion and without any obligation to communicate a specific reason.</li>');
    buffer.writeln(
        '<li>Before using the service, you must personally complete the registration form and read and accept these terms. In order to start betting on the service, we will require you to become a verified Customer which includes passing certain checks. You may be required to provide a valid proof of identification and any other document as it may be deemed necessary.</li>');
    buffer.writeln(
        '<li>This includes but is not limited to, a picture ID (copy of passport, driver’s licence or national ID card) and a recent utility bill listing your name and address as proof of residence to the minimum. We reserve the right to suspend wagering or restrict Account options on any Account until the required information is received. This procedure is a statutory requirement and is done in accordance with the applicable gaming regulation and the anti-money laundering legal requirements. Additionally, you will need to fund your 6Ball.com Account using the payment methods set out on the payment section of our Website.</li>');
    buffer.writeln(
        '<li>You must provide complete and accurate information about yourself, inclusive of a valid name, surname, address and email address, and update such information in the future to keep it complete and accurate. It is your responsibility to keep your contact details up to date on your account. Failure to do so may result in you failing to receive important account related notifications and information from us, including changes we make to these terms. We identify and communicate with our Customers via their Registered Email Address. It is the responsibility of the Customer to maintain an active and unique email account, to provide us with the correct email address and to advise 6Ball.com of any changes in their email address. Each Customer is wholly responsible for maintaining the security of his Registered Email Address to prevent the use of his Registered Email Address by any third party. 6Ball.com shall not be responsible for any damages or losses deemed or alleged to have resulted from communications between 6Ball.com and the Customer using the Registered Email Address. Any Customer not having an email address reachable by 6Ball.com will have his Account suspended until such an address is provided to us. We will immediately suspend your Account upon written notice to you to this effect if you intentionally provide false or inaccurate personal information. We may also take legal action against you for doing so in certain circumstances and/or contact the relevant authorities who may also take action against you.</li>');
    buffer.writeln(
        '<li>You are only allowed to register one Account with the service. Accounts are subject to immediate closure if it is found that you have multiple Accounts registered with us.</li>');
    buffer.writeln(
        '<li>This includes the use of representatives, relatives, associates, affiliates, related parties, connected persons and/or third parties operating on your behalf.</li>');
    buffer.writeln('<li>In order to ensure your financial worthiness and to confirm your identity, we may use any third party information providers we consider necessary.</li>');
    buffer.writeln(
        '<li>You must keep your password for the service confidential. Provided that the Account information requested has been correctly supplied, we are entitled to assume that bets, deposits and withdrawals have been made by you. We advise you to change your password on a regular basis and never disclose it to any third party. Passwords must contain at least one letter, one number and one special character and must be at least eight characters long. It is your responsibility to protect your password and any failure to do so shall be at your sole risk and expense. You must log out of the Service at the end of each session. If you believe any of your Account information is being misused by a third party, or your Account has been hacked into, or your password has been discovered by a third party, you must notify us immediately by email using your registered Email Address to support@6Ball.com</li>');
    buffer.writeln(
        '<li>You must notify us if your registered email Address has been hacked into, we may, however, require you to provide additional information/documentation so that we can verify your identity. We will immediately suspend your Account once we are aware of such an incident. In the meantime you are responsible for all activity on your Account including third party access, regardless of whether or not their access was authorised by you.</li>');
    buffer.writeln(
        '<li>You must not at any time transmit any content or other information on the service to another Customer or any other party by way of a screen capture (or other similar method), nor display any such information or content in a frame or in any other manner that is different from how it would appear if such Customer or third party had typed the URL for the service into the browser line;</li>');
    buffer.writeln(
        '<li>When registering, you will be required to choose the currency in which you will operate your account. This will be the currency of your deposits, withdrawals and bets placed and matched into the service as set out in these terms. Some payment methods do not process in all currencies. In such cases a processing currency will be displayed, along with a conversion calculator available on the page.</li>');
    buffer.writeln(
        '<li>We are under no obligation to open an account for you and our website sign-up page is merely an invitation to treat. It is entirely within our sole discretion whether or not to proceed with the opening of an account for you and, should we refuse to open an Account for you, we are under no obligation to provide you with a reason for the refusal.</li>');
    buffer.writeln(
        '<li>Upon receipt of your application, we may be in touch to request further information and/or documentation from you in order for us to comply with our regulatory and legal obligations.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>3. Restricted Use</h3>');
    buffer.writeln('<p>3.1 You must not use the Service:</p>');
    buffer.writeln('<ul>');
    buffer.writeln(
        '<li>if you are under the age of 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you) or if you are not legally able to enter into a binding legal agreement with us;</li>');
    buffer.writeln(
        '<li>to collect nicknames, e-mail addresses and/or other information of other Customers by any means (for example, by sending spam, other types of unsolicited e-mails or the unauthorised framing of, or linking to, the Service);</li>');
    buffer.writeln('<li>to disrupt or unduly affect or influence the activities of other Customers or the operation of the Service generally;.</li>');
    buffer.writeln(
        '<li>to promote unsolicited commercial advertisements, affiliate links, and other forms of solicitation which may be removed from the Service without notice;</li>');
    buffer.writeln(
        '<li>in any way which, in our reasonable opinion, could be considered as an attempt to: (i) cheat the Service or another Customer using the Service; or (ii) collude with any other Customer using the Service in order to obtain a dishonest advantage;</li>');
    buffer.writeln('<li>to scrape our odds or violate any of our Intellectual Property Rights; or</li>');
    buffer.writeln('<li>for any unlawful activity whatsoever.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<p>3.2 You cannot sell or transfer your account to third parties, nor can you acquire a player account from a third party.</p>');
    buffer.writeln('<p>3.3 You may not, in any manner, transfer funds between player accounts.</p>');
    buffer.writeln(
        '<p>3.4 We may immediately terminate your Account upon written notice to you if you use the Service for unauthorised purposes. We may also take legal action against you for doing so in certain circumstances.</p>');
    buffer.writeln('<h3>4. Privacy</h3>');
    buffer.writeln('<p>Any information provided to us by you will be protected and processed in strict accordance with these Terms and our Privacy Policy.</p>');
    buffer.writeln(
        '<p>We will not reveal the identity of any person who places bets using the service unless the information is lawfully required by competent authorities such as Regulators, the Police (e.g. to investigate fraud, money laundering or sports integrity issues), or by Financial Entities such as banks or payment suppliers or as permitted from time to time pursuant to the Privacy Policy.</p>');
    buffer.writeln(
        '<p>Upon registration, your information will be stored in our database. This means that your personal information may be transferred outside the European Economic Area (EEA) to jurisdictions that may not provide the same level of protection and security as applied within the EU or EEA. By agreeing to these Terms you agree to the transfer of your personal information for the purpose of the provision of the Service object of this agreement and as further detailed in our Privacy Policy.</p>');
    buffer.writeln('<h3>5. Your Account</h3>');
    buffer.writeln(
        '<p>We accept Accounts in multiple currencies, please refer to: https://6Ball.com/currency account balances and transactions appear in the currency selected when the account was originally opened.</p>');
    buffer.writeln('<p>We do not give credit for the use of the service.</p>');
    buffer.writeln(
        '<p>We may close or suspend an Account and refund any monies held if you are not or we reasonably believe that you are not complying with these Terms, or to ensure the integrity or fairness of the Service or if we have other reasonable grounds to do so. We may not always be able to give you prior notice.</p>');
    buffer
        .writeln('<p>We reserve the right to suspend an account without prior notice and return all funds. Contractual obligations already matured will however be honoured.</p>');
    buffer.writeln(
        '<p>We reserve the right to refuse, restrict, cancel or limit any wager at any time for whatever reason, including any bet perceived to be placed in a fraudulent manner in order to circumvent our betting limits and/or our system regulations.</p>');
    buffer.writeln('<p>If we close or suspend your account due to you not complying with these terms, we may cancel and/or void any of your bets.</p>');
    buffer.writeln(
        '<p>If any amount is mistakenly credited to your account it remains our property and when we become aware of any such mistake, we shall notify you and the amount will be withdrawn from your Account.</p>');
    buffer.writeln('<p>If, for any reason, your account goes overdrawn, you shall be in debt to us for the amount overdrawn.</p>');
    buffer.writeln('<p>You must inform us as soon as you become aware of any errors with respect to your Account.</p>');
    buffer.writeln(
        '<p>Customers have the right to self-exclude themselves from bertbarter.com. These requests have to be received from the Customer’s Registered Email Address and have to be sent to support@6Ball.com.</p>');
    buffer.writeln(
        '<p>Customers may set limitations on the amount they may wager and lose. Such request has to be sent from the Customer’s Registered Email Address to support@6Ball.com. Implementation and increasing of limits shall be processed diligently, however, any request for removing or reducing limitations shall be done after a cooling-off period of seven days following your request.</p>');
    buffer.writeln('<p>Should you wish to close your account with us, please send an email from your Registered Email Address to support@6Ball.com.</p>');
    buffer.writeln('<h3>6. Deposit of Funds</h3>');
    buffer.writeln(
        '<p>You may deposit funds into your Account by any of the methods set out on our Website. All deposits should be made in the same currency as your Account and any deposits made in any other currency will be converted using the daily exchange rate obtained from www.oanda.com, or at our own bank’s prevailing rate of exchange following which your Account will be deposited accordingly.</p>');
    buffer.writeln(
        '<p>Fees and charges may apply to customer’s deposits and withdrawals. Fee and charge details can be found here:https://www.6Ball.art/payment-options. Any deposit made to an account which is not rolled over (risked) three times will incur a 3% processing fee and any applicable withdrawal fee. You are responsible for your own bank charges that you may incur due to depositing funds with us. Exceptions to this rule are outlined in our “Payment Options” pages.</p>');
    buffer.writeln(
        '<p>6Ball.com is not a financial institution and uses a third party electronic payment processors to process credit and debit card deposits; they are not processed directly by us. If you deposit funds by either a credit card or a debit card, your Account will only be credited if we receive an approval and authorisation code from the payment issuing institution. If your card’s issuer gives no such authorisation, your account will not be credited with those funds.</p>');
    buffer.writeln('<p>Your funds are deposited and held in the respective client account based on the currency of your account.</p>');
    buffer.writeln(
        '<p>We are not a financial institution and you will not be entitled to any interest on any outstanding account balances and any interest accrued on the client accounts will be paid to us.</p>');
    buffer.writeln('<p>Funds originating from ill-gotten means must not be deposited with us.</p>');
    buffer.writeln('<h3>7. Withdrawal of Funds</h3>');
    buffer.writeln(
        '<p>You may withdraw any or all of your account Balance within the transaction maximums as shown on the Website here: https://https://www.6Ball.art//payment-options. Note that fees may apply as outlined in section 7.b.</p>');
    buffer.writeln('<p>All withdrawals must be made in the currency of your account, unless otherwise stipulated by us.</p>');
    buffer.writeln(
        '<p>We reserve the right to request documentation for the purpose of identity verification prior to granting any withdrawals from your Account. We also reserve our rights to request this documentation at any time during the lifetime of your relationship with us.</p>');
    buffer.writeln(
        '<p>All withdrawals must be made to the original debit, credit card, bank account, method of payment used to make the payment to your 6Ball.com Account. We may, and always at our own discretion, allow you to withdraw to a payment method from which your original deposit did not originate. This will always be subject to additional security checks.</p>');
    buffer.writeln(
        '<p>Should you wish to withdraw funds but your account is either inaccessible, dormant, locked or closed, please contact our Customer Service Department at support@6Ball.com</p>');
    buffer.writeln('<h3>8. Payment Transactions and Processors</h3>');
    buffer.writeln(
        '<p>You are fully responsible for paying all monies owed to us. You must make all payments to us in good faith and not attempt to reverse a payment made or take any action which will cause such payment to be reversed by a third party in order to avoid a liability legitimately incurred. You will reimburse us for any charge-backs, denial or reversal of payment you make and any loss suffered by us as a consequence thereof. We reserve the right to also impose an administration fee of €60, or currency equivalent per charge-back, denial or reversal of payment you make.</p>');
    buffer.writeln(
        '<p>We reserve the right to use third party electronic payment processors and or merchant banks to process payments made by you and you agree to be bound by their terms and conditions providing they are made aware to you and those terms do not conflict with these Terms.</p>');
    buffer.writeln(
        '<p>All transactions made on our site might be checked to prevent money laundering or terrorism financing activity. Suspicious transactions will be reported to the relevant authority depending on the jurisdiction governing the transaction.</p>');
    buffer.writeln('<h3>9. Errors</h3>');
    buffer.writeln(
        '<p>In the event of an error or malfunction of our system or processes, all bets are rendered void. You are under an obligation to inform us immediately as soon as you become aware of any error with the service. In the event of communication or system errors or bugs or viruses occurring in connection with the service and/or payments made to you as a result of a defect or effort in the Service, we will not be liable to you or to any third party for any direct or indirect costs, expenses, losses or claims arising or resulting from such errors, and we reserve the right to void all games/bets in question and take any other action to correct such errors.</p>');
    buffer.writeln(
        '<p>In the event of a casino system malfunction, or disconnection issues, all bets are rendered void. In the event of such error or any system failure or game error that results in an error in any odds calculation, charges, fees, rake, bonuses or payout, or any currency conversion as applicable, or other casino system malfunction (the “Casino Error”), we reserve the right to declare null and void any wagers or bets that were the subject of such Casino Error and to take any money from your Account relating to the relevant bets or wagers.</p>');
    buffer.writeln(
        '<p>We make every effort to ensure that we do not make errors in posting lines. However, if as a result of human error or system problems a bet is accepted at an odd that is: materially different from those available in the general market at the time the bet was made; or clearly incorrect given the chance of the event occurring at the time the bet was made then we reserve the right to cancel or void that wager, or to cancel or void a wager made after an event has started.</p>');
    buffer.writeln(
        '<p>We have the right to recover from you any amount overpaid and to adjust your account to rectify any mistake. An example of such a mistake might be where a price is incorrect or where we enter a result of an event incorrectly. If there are insufficient funds in your Account, we may demand that you pay us the relevant outstanding amount relating to any erroneous bets or wagers. Accordingly, we reserve the right to cancel, reduce or delete any pending plays, whether placed with funds resulting from the error or not.</p>');
    buffer.writeln('<h3>10. General Rules</h3>');
    buffer.writeln('<p>If a sport-specific rule contradicts a general rule, then the general rule will not apply.</p>');
    buffer.writeln(
        '<p>The winner of an event will be determined on the date of the event’s settlement; we do not recognise protested or overturned decisions for wagering purposes. The result of an event suspended after the start of competition will be decided according to the wagering rules specified for that sport by us.</p>');
    buffer.writeln(
        '<p>All results posted shall be final after 72 hours and no queries will be entertained after that period of time. Within 72 hours after results are posted, the company will only reset/correct the results due to human error, system error or mistakes made by the referring results source.</p>');
    buffer.writeln(
        '<p>Minimum and maximum wager amounts on all sporting events will be determined by us and are subject to change without prior written notice. We also reserve the right to adjust limits on individual Accounts as well.</p>');
    buffer.writeln(
        '<p>Customers are solely responsible for their own account transactions. Please be sure to review your wagers for any mistakes before sending them in. Once a transaction is complete, it cannot be changed. We do not take responsibility for missing or duplicate wagers made by the Customer and will not entertain discrepancy requests because a play is missing or duplicated. Customers may review their transactions in the My Account section of the site after each session to ensure all requested wagers were accepted.</p>');
    buffer.writeln('<p>For a wager to have action on any named contestant in a Yes/No Proposition, the contestant must enter and compete in the event.</p>');
    buffer.writeln(
        '<p>We attempt to follow the normal conventions to indicate home and away teams by indicating the home and away team by means of vertical placement on the desktop site version. This means in American Sports we would place the home team on the bottom. For Non-US sports, we would indicate the home team on top. In the case of a neutral venue, we attempt to include the letter “N” next to the team names to indicate this. For the Asian and mobile versions, we do not distinguish between European and American Sports. On the Asian and mobile versions of the site, the home team is always listed first. However, we do not guarantee the accuracy of this information and unless there is an official venue change subsequent to bets being placed, all wagers have action.</p>');
    buffer.writeln(
        '<p>A game/match will have action regardless of the League heading that is associated with the matchup. For example, two teams from the same League are playing in a Cup competition. If the matchup is mistakenly placed in the League offering, the game/match will still have action, as long as the matchup is correct. In other words, a matchup will have action as long as the two teams are correct, and regardless of the League header in which it is placed on our Website.</p>');
    buffer.writeln(
        '<p>If an event is not played on the same date as announced by the governing body, then all wagers on the event have no action. If an event is posted by us, with an incorrect date, all wagers have action based on the date announced by the governing body.</p>');
    buffer.writeln('<p>6Ball.com reserves the right to remove events, markets and any other product from the website.</p>');
    buffer.writeln('<p>6Ball.com reserves the right to restrict the casino access of any player without prior notice.</p>');
    buffer.writeln(
        '<p>In all futures wagering (for example, total season wins, Super Bowl winner, etc.), the winner as determined by the Governing Body will also be declared the winner for betting purposes except when the minimum number of games required for the future to have “action” has not been completed.</p>');
    buffer.writeln('<h3>11. Communications and Notices</h3>');
    buffer.writeln('<p>All communications and notices to be given under these terms by you to us shall be sent to support@6Ball.com</p>');
    buffer.writeln(
        '<p>All communications and notices to be given under these terms by us to you shall, unless otherwise specified in these terms, be either posted on the Website and/or sent to the Registered Email Address we hold on our system for the relevant Customer. The method of such communication shall be in our sole and exclusive discretion.</p>');
    buffer.writeln(
        '<p>All communications and notices to be given under these terms by either you or us shall be in writing in the English language when the service is not operated by 6Ball.com , and must be given to and from the Registered Email Address in your Account.</p>');
    buffer.writeln('<h3>12. Matters Beyond Our Control</h3>');
    buffer.writeln(
        '<p>We cannot be held liable for any failure or delay in providing the service due to an event of Force Majeure which could reasonably be considered to be outside our control despite our execution of reasonable preventative measures such as: an act of God; trade or labour dispute; power cut; act, failure or omission of any government or authority; obstruction or failure of telecommunication services; or any other delay or failure caused by a third party, and we will not be liable for any resulting loss or damage that you may suffer. In such an event, we reserve the right to cancel or suspend the Service without incurring any liability.</p>');
    buffer.writeln('<h3>13. Liability</h3>');
    buffer.writeln(
        '<p>TO THE EXTENT PERMITTED BY APPLICABLE LAW, WE WILL NOT COMPENSATE YOU FOR ANY REASONABLY FORESEEABLE LOSS OR DAMAGE (EITHER DIRECT OR INDIRECT) YOU MAY SUFFER IF WE FAIL TO CARRY OUT OUR OBLIGATIONS UNDER THESE TERMS UNLESS WE BREACH ANY DUTIES IMPOSED ON US BY LAW (INCLUDING IF WE CAUSE DEATH OR PERSONAL INJURY BY OUR NEGLIGENCE) IN WHICH CASE WE SHALL NOT BE LIABLE TO YOU IF THAT FAILURE IS ATTRIBUTED TO</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>(I) YOUR OWN FAULT;</li>');
    buffer.writeln(
        '<li>(II) A THIRD PARTY UNCONNECTED WITH OUR PERFORMANCE OF THESE TERMS (FOR INSTANCE PROBLEMS DUE TO COMMUNICATIONS NETWORK PERFORMANCE, CONGESTION, AND CONNECTIVITY OR THE PERFORMANCE OF YOUR COMPUTER EQUIPMENT); OR</li>');
    buffer.writeln(
        '<li>(III) ANY OTHER EVENTS WHICH NEITHER WE NOR OUR SUPPLIERS COULD HAVE FORESEEN OR FORESTALLED EVEN IF WE OR THEY HAD TAKEN REASONABLE CARE. AS THIS SERVICE IS FOR CONSUMER USE ONLY WE WILL NOT BE LIABLE FOR ANY BUSINESS LOSSES OF ANY KIND.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>IN THE EVENT THAT WE ARE HELD LIABLE FOR ANY EVENT UNDER THESE TERMS, OUR TOTAL AGGREGATE LIABILITY TO YOU UNDER OR IN CONNECTION WITH THESE TERMS SHALL NOT EXCEED</p>');
    buffer.writeln('<ul>');
    buffer.writeln(
        '<li>(A) THE VALUE OF THE BETS AND OR WAGERS YOU PLACED VIA YOUR ACCOUNT IN RESPECT OF THE RELEVANT BET/WAGER OR PRODUCT THAT GAVE RISE TO THE RELEVANT LIABILITY, OR</li>');
    buffer.writeln('<li>(B) EUR €500 IN AGGREGATE, WHICHEVER IS LOWER.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>WE STRONGLY RECOMMEND THAT YOU (I) TAKE CARE TO VERIFY THE SUITABILITY AND COMPATIBILITY OF THE SERVICE WITH YOUR OWN COMPUTER EQUIPMENT PRIOR TO USE; AND (II) TAKE REASONABLE PRECAUTIONS TO PROTECT YOURSELF AGAINST HARMFUL PROGRAMS OR DEVICES INCLUDING THROUGH INSTALLATION OF ANTI-VIRUS SOFTWARE.</p>');
    buffer.writeln('<h3>14. Gambling By Those Under Age</h3>');
    buffer.writeln(
        '<p>If we suspect that you are or receive notification that you are currently under 18 years or were under 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you) when you placed any bets through the service your account will be suspended to prevent you placing any further bets or making any withdrawals from your account. We will then investigate the matter, including whether you have been betting as an agent for, or otherwise on behalf, of a person under 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you). If having found that you: (a) are currently; (b) were under 18 years or below the majority age which applies to you at the relevant time; or (c) have been betting as an agent for or at the behest of a person under 18 years or below the majority age which applies:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>all winnings currently or due to be credited to your account will be retained;</li>');
    buffer.writeln(
        '<li>all winnings gained from betting through the service whilst under age must be paid to us on demand (if you fail to comply with this provision we will seek to recover all costs associated with recovery of such sums); and/or</li>');
    buffer.writeln('<li>any monies deposited in your 6Ball.com account which are not winnings will be returned to you.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>This condition also applies to you if you are over the age of 18 years but you are placing your bets within a jurisdiction which specifies a higher age than 18 years for legal betting and you are below that legal minimum age in that jurisdiction.</p>');
    buffer.writeln(
        '<p>In the event we suspect you are in breach of the provisions of this Clause 15 or are attempting to rely on them for a fraudulent purpose, we reserve the right to take any action necessary in order to investigate the matter, including informing the relevant law enforcement agencies.</p>');
    buffer.writeln('<h3>15. Fraud</h3>');
    buffer.writeln(
        '<p>We will seek criminal and contractual sanctions against any Customer involved in fraud, dishonesty or criminal acts. We will withhold payment to any Customer where any of these are suspected. The Customer shall indemnify and shall be liable to pay to us on demand, all costs, charges or losses sustained or incurred by us (including any direct, indirect or consequential losses, loss of profit, loss of business and loss of reputation) arising directly or indirectly from the Customer’s fraud, dishonesty or criminal act.</p>');
    buffer.writeln('<h3>16. Intellectual Property</h3>');
    buffer.writeln(
        '<p>We trade as 6Ball.com and the 6Ball.com name and logo are registered trademarks. Any unauthorised use of our trademark and logo may result in legal action being taken against you.</p>');
    buffer.writeln(
        '<p>The https://www.6Ball.art/ uniform resource locator (URL) is owned by us and no unauthorised use of the URL is permitted on another website or digital platform without our prior written consent.</p>');
    buffer.writeln(
        '<p>As between us and you, we are the sole owners of the rights in and to the Service, our technology, software and business systems (the “Systems”) as well as our odds.</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>you must not use your personal profile for your own commercial gain (such as selling your status update to an advertiser); and</li>');
    buffer.writeln('<li>when selecting a nickname for your Account we reserve the right to remove or reclaim it if we believe it appropriate.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>You may not use our URL, trademarks, trade names and/or trade dress, logos (the “Marks”) and/or our odds in connection with any product or service that is not ours, that in any manner is likely to cause confusion among Customers or in the public or that in any manner disparages us.</p>');
    buffer.writeln(
        '<p>Except as expressly provided in these Terms, we and our licensors do not grant you any express or implied rights, licence, title or interest in or to the Systems or the Marks and all such rights, licence, title and interest specifically retained by us and our licensors. You agree not to use any automatic or manual device to monitor or copy web pages or content within the Service. Any unauthorised use or reproduction may result in legal action being taken against you.</p>');
    buffer.writeln('<h3>17. Your Licence</h3>');
    buffer.writeln(
        '<p>Subject to these terms and your compliance with them, we grant to you a non-exclusive, limited, non transferable and non sub-licensable licence to access and use the Service for your personal non-commercial purposes only. Our licence to you terminates if our agreement with you under these Terms ends.</p>');
    buffer.writeln(
        '<p>Save in respect of your own content, you may not under any circumstances modify, publish, transmit, transfer, sell, reproduce, upload, post, distribute, perform, display, create derivative works from, or in any other manner exploit, the service and/or any of the content thereon or the software contained therein, except as we expressly permit in these terms or otherwise on the website. No information or content on the service or made available to you in connection with the Service may be modified or altered, merged with other data or published in any form including for example screen or database scraping and any other activity intended to collect, store, reorganise or manipulate such information or content.</p>');
    buffer.writeln(
        '<p>Any non-compliance by you with this Clause may also be a violation of our or third parties’ intellectual property and other proprietary rights which may subject you to civil liability and/or criminal prosecution.</p>');
    buffer.writeln('<h3>18. Your Conduct and Safety</h3>');
    buffer.writeln(
        '<p>We would like you to enjoy the Service. However, for your protection and that of all Customers, the posting of any content on the service, as well as conduct in connection therewith and/or the service, which is in any way unlawful, inappropriate or undesirable is strictly prohibited - it is Prohibited Behaviour. If you engage in Prohibited Behaviour, or we determine in our sole discretion that you are engaging in Prohibited Behaviour, your 6Ball.com Account and/or your access to or use of the Service may be terminated immediately without notice to you.</p>');
    buffer.writeln(
        '<p>Legal action may be taken against you by another Customer, other third party, enforcement authorities and/or us with respect to you having engaged in Prohibited Behaviour.</p>');
    buffer.writeln('<p>Prohibited Behaviour includes, but is not limited to, accessing or using the Service to:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>promote or share information that you know is false, misleading or unlawful;</li>');
    buffer.writeln(
        '<li>conduct any unlawful or illegal activity, such as, but not limited to, any activity that furthers or promotes any criminal activity or enterprise, provides instructional information about making or buying weapons, violates another Customer’s or any other third party’s privacy or other rights or that creates or spreads computer viruses;</li>');
    buffer.writeln('<li>harm minors in any way;</li>');
    buffer.writeln(
        '<li>transmit or make available any content that is unlawful, harmful, threatening, abusive, tortuous, defamatory, vulgar, obscene, lewd, violent, hateful, or racially or ethnically or otherwise objectionable;</li>');
    buffer.writeln(
        '<li>transmit or make available any content that the user does not have a right to make available under any law or contractual or fiduciary relationship, including without limitation, any content that infringes a third party’s copyright, trademark or other intellectual property and proprietary rights;</li>');
    buffer.writeln(
        '<li>transmit or make available any content or material that contains any software virus or other computer or programming code (including HTML) designed to interrupt, destroy or alter the functionality of the Service, its presentation or any other website, computer software or hardware;</li>');
    buffer.writeln(
        '<li>interfere with, disrupt or reverse engineer the Service in any manner, including, without limitation, intercepting, emulating or redirecting the communication protocols used by us, creating or using cheats, mods or hacks or any other software designed to modify the Service, or using any software that intercepts or collects information from or through the Service;</li>');
    buffer.writeln('<li>retrieve or index any information from the Service using any robot, spider or other automated mechanism;</li>');
    buffer.writeln(
        '<li>participate in any activity or action that, in the sole and entire unfettered discretion of us results or may result in another Customer being defrauded or scammed;</li>');
    buffer.writeln(
        '<li>transmit or make available any unsolicited or unauthorised advertising or mass mailing such as, but not limited to, junk mail, instant messaging, "spim", "spam", chain letters, pyramid schemes or other forms of solicitations;</li>');
    buffer.writeln('<li>create 6Ball.com Accounts by automated means or under false or fraudulent pretences;</li>');
    buffer.writeln('<li>impersonate another Customer or any other third party; or</li>');
    buffer.writeln('<li>any other act or thing done that we reasonably consider to be contrary to our business principles.</li>');
    buffer.writeln('</ul>');
    buffer.writeln(
        '<p>The above list of Prohibited Behaviour is not exhaustive and may be modified by us at any time or from time to time. If you become aware of the misuse of the service by another Customer or any other person, please contact us through the “Contact Us” section of the Website. We reserve the right to investigate and to take all such actions as we in our sole discretion deems appropriate or necessary under the circumstances, including without limitation, deleting the Customer’s posting(s) from the Service and/or terminating their account, and take any action against any Customer or third party who directly or indirectly in, or knowingly permits any third party to directly or indirectly engage in, Prohibited Behaviour, with or without notice to such Customer or third party.</p>');
    buffer.writeln('<h3>19. Links to Other Websites</h3>');
    buffer.writeln(
        '<p>The Service may contain links to third party websites that are not maintained by, or related to, us, and over which we have no control. Links to such websites are provided solely as a convenience to Customers, and are in no way investigated, monitored or checked for accuracy or completeness by us. Links to such websites do not imply any endorsement by us of, and/or any affiliation with, the linked websites or their content or their owner(s). We have no control over or responsibility for the availability nor their accuracy, completeness, accessibility and usefulness. Accordingly when accessing such websites we recommend that you should take the usual precautions when visiting a new website including reviewing their privacy policy and terms of use.</p>');
    buffer.writeln('<h3>20. Complaints</h3>');
    buffer.writeln('<p>If you have any concerns or questions regarding these terms you should contact our Customer Service Department via email at support@6Ball.com.</p>');
    buffer.writeln(
        '<p>NOTWITHSTANDING THE FOREGOING, WE TAKE NO LIABILITY WHATSOEVER TO YOU OR TO ANY THIRD PARTY WHEN RESPONDING TO ANY COMPLAINT THAT WE RECEIVED OR TOOK ACTION IN CONNECTION THEREWITH.</p>');
    buffer.writeln(
        '<p>Any Customer of the Service who has any concerns or questions regarding these Terms regarding the settlement of any 6Ball.com market should contact our Customer Service Department at support@6Ball.com using their Registered Email Address.</p>');
    buffer.writeln(
        '<p>If a Customer is not satisfied with how a bet has been settled then the Customer should provide details of their grievance to our Customer Service Department via email at support@6Ball.com We shall use our reasonable endeavours to respond to queries of this nature within a few days (and in any event we intend to respond to all such queries within 28 days of receipt).</p>');
    buffer.writeln(
        '<p>Disputes must be lodged within three (3) days from the date the wager in question has been decided. No claims will be honored after this period. The Customer is solely responsible for their Account transactions. Complaints/disputes have to be sent to support@6Ball.com and must be sent from the Customer’s Registered Email Address.</p>');
    buffer.writeln(
        '<p>In the event of a dispute arising between you and us our Customer Service Department will attempt to reach an agreed solution. Should our Customer Service Department be unable to reach an agreed solution with you, the matter will be escalated to our management in accordance with our Complaints Procedure (available upon request).</p>');
    buffer.writeln(
        '<p>The Customer has the right to lodge a complaint with one of our licensing bodies should all efforts to resolve a dispute to the Customer’s satisfaction have failed.</p>');
    buffer.writeln('<h3>21. Registration and Account Security</h3>');
    buffer.writeln(
        '<p>Customers of the service must provide their real names and information and, in order to comply with this, all Customers must commit to the following rules when registering & maintaining your Account:</p>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>you must not provide any false personal information on the Service, or create an Account for anyone other than yourself;</li>');
    buffer.writeln('<li>you must not use your personal profile for your own commercial gain (such as selling your status update to an advertiser); and</li>');
    buffer.writeln('<li>when selecting a nickname for your Account we reserve the right to remove or reclaim it if we believe appropriate.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('<h3>22. Assignment</h3>');
    buffer.writeln(
        '<p>Neither these terms nor any of the rights or obligations hereunder may be assigned by you without the prior written consent of us, which consent will not be unreasonably withheld. We may, without your consent, assign all or any portion of our rights and obligations hereunder to any third party provided such third party is able to provide a service of substantially similar quality to the Service by posting written notice to this effect on the Service.</p>');
    buffer.writeln('<h3>23. Severability</h3>');
    buffer.writeln(
        '<p>In the event that any provision of these terms is deemed by any competent authority to be unenforceable or invalid, the relevant provision shall be modified to allow it to be enforced in line with the intention of the original text to the fullest extent permitted by applicable law. The validity and enforceability of the remaining provisions of these terms shall not be affected.</p>');
    buffer.writeln('<h3>24. Breach of These Terms</h3>');
    buffer.writeln(
        '<p>Without limiting our other remedies, we may suspend or terminate your account and refuse to continue to provide you with the service, in either case without giving you prior notice, if, in our reasonable opinion, you breach any material term of these Terms. Notice of any such action taken will, however, be promptly provided to you.</p>');
    buffer.writeln('<h3>25. Governing Law and Jurisdiction</h3>');
    buffer.writeln(
        '<p>This Agreement shall in all respects be governed, interpreted by, and construed in accordance with the laws of Curacao. All disputes, differences, complaints etc., shall be subject to Arbitration under the Curacao. The arbitrator will be appointed by the company after due consent from the company and the user. The place of arbitration shall be Curacao.</p>');
    buffer.writeln('<h3>26. General Provisions</h3>');
    buffer.writeln(
        '<p>Term of agreement. These terms shall remain in full force and effect while you access or use the service or are a Customer of 6Ball.com. These terms will survive the termination of your 6Ball.com Account for any reason.</p>');
    buffer.writeln(
        '<p>Gender. Words importing the singular number shall include the plural and vice versa, words importing the masculine gender shall include the feminine and neuter genders and vice versa and words importing persons shall include individuals, partnerships, associations, trusts, unincorporated organisations and corporations.</p>');
    buffer.writeln(
        '<p>Waiver. No waiver by us, whether by conduct or otherwise, of a breach or threatened breach by you of any term or condition of these Terms shall be effective against, or binding upon, us unless made in writing and duly signed by us, and, unless otherwise provided in the written waiver, shall be limited to the specific breach waived. The failure of us to enforce at any time any term or condition of these Terms shall not be construed to be a waiver of such provision or of the right of us to enforce such provision at any other time.</p>');
    buffer.writeln(
        '<p>Headings. The division of these Terms into paragraphs and sub-paragraphs and the insertion of headings are for convenience of reference only, and shall not affect or be utilised in the construction or interpretation of these Terms agreement. The terms "these Terms", "hereof", “hereunder” and similar expressions refer to these Terms and not to any particular paragraph or sub-paragraph or other portion hereof and include any agreement supplemental hereto. Unless the subject matter or context is inconsistent therewith, references herein to paragraphs and sub-paragraphs are to paragraphs and sub-paragraphs of these Terms.</p>');
    buffer.writeln(
        '<p>Acknowledgement. By hereafter accessing or using the Service, you acknowledge having read, understood and agreed to each and every paragraph of these Terms. As a result, you hereby irrevocably waive any future argument, claim, demand or proceeding to the contrary of anything contained in these Terms.</p>');
    buffer.writeln(
        '<p>Language. In the event of there being a discrepancy between the English language version of these rules and any other language version, the English language version will be deemed to be correct.</p>');
    buffer.writeln(
        '<p>Entire agreement. These Terms constitute the entire agreement between you and us with respect to your access to and use of the Service, and supersedes all other prior agreements and communications, whether oral or written with respect to the subject matter hereof.</p>');
    buffer.writeln('<h3>Betting Rules</h3>');
    buffer.writeln('<p>Any dispute related to the sports betting product shall be emailed to: support@6Ball.com</p>');
    buffer.writeln('<h3>Casino Rules</h3>');
    buffer.writeln('<p>Any dispute related to the casino product shall be emailed to: support@6Ball.com</p>');
    buffer.writeln('<p>Complete casino rules can be accessed from within the casino games.</p>');
    buffer.writeln('<h3>ACCEPTING THE TERMS AND CONDITIONS</h3>');
    buffer.writeln('<p>You hereby accept the fact that you have read, understood and are willing to abide by the above Terms and Conditions.</p>');
    buffer.writeln('<h3>Casino Payout restrictions</h3>');
    buffer.writeln('<ul>');
    buffer.writeln('<li>Restriction of payout is applicable for all Casino games</li>');
    buffer.writeln(
        '<li>In Single round, User is eligible for a max payout of 100 times his bet amount, example if the bet is 100 then max payout shall be 100 X 100 = 10000, any winning above this multiplier shall not be paid out by the company.</li>');
    buffer.writeln(
        '<li>Another restriction is max payout amount is capped at 2,00,00,000 (2 Crore points) , if net winning amount is beyond this amount then user shall be paid only this amount as max winning in Casino games.</li>');
    buffer.writeln('</ul>');
    buffer.writeln('</div></div></div></body></html>');
    return buffer.toString();
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  static const _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111111),
    letterSpacing: 0.3,
  );

  static const _sectionStyle = TextStyle(
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

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(text, style: _sectionStyle),
      );

  Widget _paragraph(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: _bodyStyle),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: _bodyStyle),
            Expanded(child: Text(text, style: _bodyStyle)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                  const Text('Terms & Conditions', style: _titleStyle),
                  const SizedBox(height: 18),
                  _paragraph('Description: Initial Terms and Conditions replacing general rules'),
                  _sectionTitle('Introduction'),
                  _paragraph(
                      'These terms and conditions and the documents referred and linked to below (the “Terms”) set out the basis upon which the website operated under the URL https://6ball.com/?cb=1776314963731 (the “Website”) and its related or connected services (collectively, the “Service”) will be provided to you.'),
                  _paragraph(
                      'Please read these terms very carefully as they form a binding legal agreement between you - our customer (the “Customer”) - and us. By opening an account (the “Account”) and using the Service you agree to be bound by these terms, together with any amendment which may be published from time to time.'),
                  _paragraph('If anything is not clear to you please contact us using the contact details below.'),
                  _paragraph('The Service is supplied by 6Ball.'),
                  _paragraph(
                      'Transactions and payment services are operated by 6Ball a limited liability company registered in Curacao, with company registration number 133567 and holding a license no. 365/JAZ Sub-License GLH- OCCHKTW0707072017.'),
                  _paragraph(
                      '6Ball.com will only communicate with Customers by email to their registered email address (the “Registered Email Address”) as provided when opening your 6Ball account: Communication from 6Ball.com will be issued through the following: mail only: support@6Ball.com'),
                  _sectionTitle('General Terms'),
                  _paragraph(
                      'We reserve the right to amend the terms (including to any documents referred and linked to below) at any time. When such amendment is not substantial, we may not provide you with prior notice. You will be notified in advance for material changes to the terms and may require you to re-confirm acceptance to the updated terms before the changes come into effect. If you object to any such changes, you must immediately stop using the service and the termination provisions below will apply. Continued use of the service indicates your agreement to be bound by such changes. Any bets not settled prior to the changed terms taking effect will be subject to the pre-existing terms.'),
                  _paragraph(
                      'If at any time you are in any doubt about how to place bets or otherwise use the service you should refer back to these terms or contact our customer service department (Customer Service Department) at support@6Ball.com'),
                  _sectionTitle('1. Your Obligations'),
                  _paragraph('You agree that at all times when using the Service:'),
                  _bullet(
                      'You are over 18 years of age (or over the age of majority as stipulated in the laws of the jurisdiction applicable to you) and can enter into a binding legal agreement with us.'),
                  _bullet(
                      'It is the User’s responsibility to check and enter this site only if the user is in a country where it is lawful to place bets on the service (if in doubt, you should seek local legal advice). It is your responsibility to ensure that your use of the service is legal.'),
                  _bullet('When sending money to us you are authorised to do so e.g. you are the authorised user of the debit/credit card or other payment method you use.'),
                  _bullet(
                      'You will not, by participating in the Services and/or placing bets be placed in a position of actual, potential or perceived conflict of interest in any manner.'),
                  _bullet('You have never failed to pay, or attempted to fail to pay a liability on a bet.'),
                  _bullet(
                      'You are acting solely on your own behalf as a private individual in a personal capacity and not on behalf of another party or for any commercial purposes.'),
                  _bullet('By placing bets you may lose some or all of your money lodged with us in accordance with these terms and you will be fully responsible for that loss.'),
                  _bullet(
                      'You must use the service for legitimate betting purposes only and must not nor attempt to manipulate any market or element within the service in bad faith or in a manner that adversely affects the integrity of the Service or us.'),
                  _bullet(
                      'When placing bets on the service you must not use any information obtained in breach of any legislation in force in the country in which you were when the bet was placed.'),
                  _bullet(
                      'You must make all payments to us in good faith and not attempt to reverse a payment made or take any action which will cause such payment to be reversed by a third party in order to avoid a liability legitimately incurred.'),
                  _bullet('You must otherwise generally act in good faith in relation to us of the service at all times and for all bets made through the service.'),
                  _sectionTitle('2. Registration'),
                  _paragraph('You agree that at all times when using the service:'),
                  _bullet(
                      'In order to protect the integrity of the service and for other operational reasons we reserve the right to refuse to accept a registration application from any applicant at our sole discretion and without any obligation to communicate a specific reason.'),
                  _bullet(
                      'Before using the service, you must personally complete the registration form and read and accept these terms. In order to start betting on the service, we will require you to become a verified Customer which includes passing certain checks. You may be required to provide a valid proof of identification and any other document as it may be deemed necessary.'),
                  _bullet(
                      'This includes but is not limited to, a picture ID (copy of passport, driver’s licence or national ID card) and a recent utility bill listing your name and address as proof of residence to the minimum. We reserve the right to suspend wagering or restrict Account options on any Account until the required information is received. This procedure is a statutory requirement and is done in accordance with the applicable gaming regulation and the anti-money laundering legal requirements. Additionally, you will need to fund your 6Ball.com Account using the payment methods set out on the payment section of our Website.'),
                  _bullet(
                      'You must provide complete and accurate information about yourself, inclusive of a valid name, surname, address and email address, and update such information in the future to keep it complete and accurate. It is your responsibility to keep your contact details up to date on your account. Failure to do so may result in you failing to receive important account related notifications and information from us, including changes we make to these terms. We identify and communicate with our Customers via their Registered Email Address. It is the responsibility of the Customer to maintain an active and unique email account, to provide us with the correct email address and to advise 6Ball.com of any changes in their email address. Each Customer is wholly responsible for maintaining the security of his Registered Email Address to prevent the use of his Registered Email Address by any third party. 6Ball.com shall not be responsible for any damages or losses deemed or alleged to have resulted from communications between 6Ball.com and the Customer using the Registered Email Address. Any Customer not having an email address reachable by 6Ball.com will have his Account suspended until such an address is provided to us. We will immediately suspend your Account upon written notice to you to this effect if you intentionally provide false or inaccurate personal information. We may also take legal action against you for doing so in certain circumstances and/or contact the relevant authorities who may also take action against you.'),
                  _bullet(
                      'You are only allowed to register one Account with the service. Accounts are subject to immediate closure if it is found that you have multiple Accounts registered with us.'),
                  _bullet(
                      'This includes the use of representatives, relatives, associates, affiliates, related parties, connected persons and/or third parties operating on your behalf.'),
                  _bullet('In order to ensure your financial worthiness and to confirm your identity, we may use any third party information providers we consider necessary.'),
                  _bullet(
                      'You must keep your password for the service confidential. Provided that the Account information requested has been correctly supplied, we are entitled to assume that bets, deposits and withdrawals have been made by you. We advise you to change your password on a regular basis and never disclose it to any third party. Passwords must contain at least one letter, one number and one special character and must be at least eight characters long. It is your responsibility to protect your password and any failure to do so shall be at your sole risk and expense. You must log out of the Service at the end of each session. If you believe any of your Account information is being misused by a third party, or your Account has been hacked into, or your password has been discovered by a third party, you must notify us immediately by email using your registered Email Address to support@6Ball.com'),
                  _bullet(
                      'You must notify us if your registered email Address has been hacked into, we may, however, require you to provide additional information/documentation so that we can verify your identity. We will immediately suspend your Account once we are aware of such an incident. In the meantime you are responsible for all activity on your Account including third party access, regardless of whether or not their access was authorised by you.'),
                  _bullet(
                      'You must not at any time transmit any content or other information on the service to another Customer or any other party by way of a screen capture (or other similar method), nor display any such information or content in a frame or in any other manner that is different from how it would appear if such Customer or third party had typed the URL for the service into the browser line;'),
                  _bullet(
                      'When registering, you will be required to choose the currency in which you will operate your account. This will be the currency of your deposits, withdrawals and bets placed and matched into the service as set out in these terms. Some payment methods do not process in all currencies. In such cases a processing currency will be displayed, along with a conversion calculator available on the page.'),
                  _bullet(
                      'We are under no obligation to open an account for you and our website sign-up page is merely an invitation to treat. It is entirely within our sole discretion whether or not to proceed with the opening of an account for you and, should we refuse to open an Account for you, we are under no obligation to provide you with a reason for the refusal.'),
                  _bullet(
                      'Upon receipt of your application, we may be in touch to request further information and/or documentation from you in order for us to comply with our regulatory and legal obligations.'),
                  _sectionTitle('3. Restricted Use'),
                  _paragraph('3.1 You must not use the Service:'),
                  _bullet(
                      'if you are under the age of 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you) or if you are not legally able to enter into a binding legal agreement with us;'),
                  _bullet(
                      'to collect nicknames, e-mail addresses and/or other information of other Customers by any means (for example, by sending spam, other types of unsolicited e-mails or the unauthorised framing of, or linking to, the Service);'),
                  _bullet('to disrupt or unduly affect or influence the activities of other Customers or the operation of the Service generally;.'),
                  _bullet(
                      'to promote unsolicited commercial advertisements, affiliate links, and other forms of solicitation which may be removed from the Service without notice;'),
                  _bullet(
                      'in any way which, in our reasonable opinion, could be considered as an attempt to: (i) cheat the Service or another Customer using the Service; or (ii) collude with any other Customer using the Service in order to obtain a dishonest advantage;'),
                  _bullet('to scrape our odds or violate any of our Intellectual Property Rights; or'),
                  _bullet('for any unlawful activity whatsoever.'),
                  _paragraph('3.2 You cannot sell or transfer your account to third parties, nor can you acquire a player account from a third party.'),
                  _paragraph('3.3 You may not, in any manner, transfer funds between player accounts.'),
                  _paragraph(
                      '3.4 We may immediately terminate your Account upon written notice to you if you use the Service for unauthorised purposes. We may also take legal action against you for doing so in certain circumstances.'),
                  _sectionTitle('4. Privacy'),
                  _paragraph('Any information provided to us by you will be protected and processed in strict accordance with these Terms and our Privacy Policy.'),
                  _paragraph(
                      'We will not reveal the identity of any person who places bets using the service unless the information is lawfully required by competent authorities such as Regulators, the Police (e.g. to investigate fraud, money laundering or sports integrity issues), or by Financial Entities such as banks or payment suppliers or as permitted from time to time pursuant to the Privacy Policy.'),
                  _paragraph(
                      'Upon registration, your information will be stored in our database. This means that your personal information may be transferred outside the European Economic Area (EEA) to jurisdictions that may not provide the same level of protection and security as applied within the EU or EEA. By agreeing to these Terms you agree to the transfer of your personal information for the purpose of the provision of the Service object of this agreement and as further detailed in our Privacy Policy.'),
                  _sectionTitle('5. Your Account'),
                  _paragraph(
                      'We accept Accounts in multiple currencies, please refer to: https://6Ball.com/currency account balances and transactions appear in the currency selected when the account was originally opened.'),
                  _paragraph('We do not give credit for the use of the service.'),
                  _paragraph(
                      'We may close or suspend an Account and refund any monies held if you are not or we reasonably believe that you are not complying with these Terms, or to ensure the integrity or fairness of the Service or if we have other reasonable grounds to do so. We may not always be able to give you prior notice.'),
                  _paragraph(
                      'We reserve the right to suspend an account without prior notice and return all funds. Contractual obligations already matured will however be honoured.'),
                  _paragraph(
                      'We reserve the right to refuse, restrict, cancel or limit any wager at any time for whatever reason, including any bet perceived to be placed in a fraudulent manner in order to circumvent our betting limits and/or our system regulations.'),
                  _paragraph('If we close or suspend your account due to you not complying with these terms, we may cancel and/or void any of your bets.'),
                  _paragraph(
                      'If any amount is mistakenly credited to your account it remains our property and when we become aware of any such mistake, we shall notify you and the amount will be withdrawn from your Account.'),
                  _paragraph('If, for any reason, your account goes overdrawn, you shall be in debt to us for the amount overdrawn.'),
                  _paragraph('You must inform us as soon as you become aware of any errors with respect to your Account.'),
                  _paragraph(
                      'Customers have the right to self-exclude themselves from bertbarter.com. These requests have to be received from the Customer’s Registered Email Address and have to be sent to support@6Ball.com.'),
                  _paragraph(
                      'Customers may set limitations on the amount they may wager and lose. Such request has to be sent from the Customer’s Registered Email Address to support@6Ball.com. Implementation and increasing of limits shall be processed diligently, however, any request for removing or reducing limitations shall be done after a cooling-off period of seven days following your request.'),
                  _paragraph('Should you wish to close your account with us, please send an email from your Registered Email Address to support@6Ball.com.'),
                  _sectionTitle('6. Deposit of Funds'),
                  _paragraph(
                      'You may deposit funds into your Account by any of the methods set out on our Website. All deposits should be made in the same currency as your Account and any deposits made in any other currency will be converted using the daily exchange rate obtained from www.oanda.com, or at our own bank’s prevailing rate of exchange following which your Account will be deposited accordingly.'),
                  _paragraph(
                      'Fees and charges may apply to customer’s deposits and withdrawals. Fee and charge details can be found here:https://www.6Ball.art/payment-options. Any deposit made to an account which is not rolled over (risked) three times will incur a 3% processing fee and any applicable withdrawal fee. You are responsible for your own bank charges that you may incur due to depositing funds with us. Exceptions to this rule are outlined in our “Payment Options” pages.'),
                  _paragraph(
                      '6Ball.com is not a financial institution and uses a third party electronic payment processors to process credit and debit card deposits; they are not processed directly by us. If you deposit funds by either a credit card or a debit card, your Account will only be credited if we receive an approval and authorisation code from the payment issuing institution. If your card’s issuer gives no such authorisation, your account will not be credited with those funds.'),
                  _paragraph('Your funds are deposited and held in the respective client account based on the currency of your account.'),
                  _paragraph(
                      'We are not a financial institution and you will not be entitled to any interest on any outstanding account balances and any interest accrued on the client accounts will be paid to us.'),
                  _paragraph('Funds originating from ill-gotten means must not be deposited with us.'),
                  _sectionTitle('7. Withdrawal of Funds'),
                  _paragraph(
                      'You may withdraw any or all of your account Balance within the transaction maximums as shown on the Website here: https://https://www.6Ball.art//payment-options. Note that fees may apply as outlined in section 7.b.'),
                  _paragraph('All withdrawals must be made in the currency of your account, unless otherwise stipulated by us.'),
                  _paragraph(
                      'We reserve the right to request documentation for the purpose of identity verification prior to granting any withdrawals from your Account. We also reserve our rights to request this documentation at any time during the lifetime of your relationship with us.'),
                  _paragraph(
                      'All withdrawals must be made to the original debit, credit card, bank account, method of payment used to make the payment to your 6Ball.com Account. We may, and always at our own discretion, allow you to withdraw to a payment method from which your original deposit did not originate. This will always be subject to additional security checks.'),
                  _paragraph(
                      'Should you wish to withdraw funds but your account is either inaccessible, dormant, locked or closed, please contact our Customer Service Department at support@6Ball.com'),
                  _sectionTitle('8. Payment Transactions and Processors'),
                  _paragraph(
                      'You are fully responsible for paying all monies owed to us. You must make all payments to us in good faith and not attempt to reverse a payment made or take any action which will cause such payment to be reversed by a third party in order to avoid a liability legitimately incurred. You will reimburse us for any charge-backs, denial or reversal of payment you make and any loss suffered by us as a consequence thereof. We reserve the right to also impose an administration fee of €60, or currency equivalent per charge-back, denial or reversal of payment you make.'),
                  _paragraph(
                      'We reserve the right to use third party electronic payment processors and or merchant banks to process payments made by you and you agree to be bound by their terms and conditions providing they are made aware to you and those terms do not conflict with these Terms.'),
                  _paragraph(
                      'All transactions made on our site might be checked to prevent money laundering or terrorism financing activity. Suspicious transactions will be reported to the relevant authority depending on the jurisdiction governing the transaction.'),
                  _sectionTitle('9. Errors'),
                  _paragraph(
                      'In the event of an error or malfunction of our system or processes, all bets are rendered void. You are under an obligation to inform us immediately as soon as you become aware of any error with the service. In the event of communication or system errors or bugs or viruses occurring in connection with the service and/or payments made to you as a result of a defect or effort in the Service, we will not be liable to you or to any third party for any direct or indirect costs, expenses, losses or claims arising or resulting from such errors, and we reserve the right to void all games/bets in question and take any other action to correct such errors.'),
                  _paragraph(
                      'In the event of a casino system malfunction, or disconnection issues, all bets are rendered void. In the event of such error or any system failure or game error that results in an error in any odds calculation, charges, fees, rake, bonuses or payout, or any currency conversion as applicable, or other casino system malfunction (the “Casino Error”), we reserve the right to declare null and void any wagers or bets that were the subject of such Casino Error and to take any money from your Account relating to the relevant bets or wagers.'),
                  _paragraph(
                      'We make every effort to ensure that we do not make errors in posting lines. However, if as a result of human error or system problems a bet is accepted at an odd that is: materially different from those available in the general market at the time the bet was made; or clearly incorrect given the chance of the event occurring at the time the bet was made then we reserve the right to cancel or void that wager, or to cancel or void a wager made after an event has started.'),
                  _paragraph(
                      'We have the right to recover from you any amount overpaid and to adjust your account to rectify any mistake. An example of such a mistake might be where a price is incorrect or where we enter a result of an event incorrectly. If there are insufficient funds in your Account, we may demand that you pay us the relevant outstanding amount relating to any erroneous bets or wagers. Accordingly, we reserve the right to cancel, reduce or delete any pending plays, whether placed with funds resulting from the error or not.'),
                  _sectionTitle('10. General Rules'),
                  _paragraph('If a sport-specific rule contradicts a general rule, then the general rule will not apply.'),
                  _paragraph(
                      'The winner of an event will be determined on the date of the event’s settlement; we do not recognise protested or overturned decisions for wagering purposes. The result of an event suspended after the start of competition will be decided according to the wagering rules specified for that sport by us.'),
                  _paragraph(
                      'All results posted shall be final after 72 hours and no queries will be entertained after that period of time. Within 72 hours after results are posted, the company will only reset/correct the results due to human error, system error or mistakes made by the referring results source.'),
                  _paragraph(
                      'Minimum and maximum wager amounts on all sporting events will be determined by us and are subject to change without prior written notice. We also reserve the right to adjust limits on individual Accounts as well.'),
                  _paragraph(
                      'Customers are solely responsible for their own account transactions. Please be sure to review your wagers for any mistakes before sending them in. Once a transaction is complete, it cannot be changed. We do not take responsibility for missing or duplicate wagers made by the Customer and will not entertain discrepancy requests because a play is missing or duplicated. Customers may review their transactions in the My Account section of the site after each session to ensure all requested wagers were accepted.'),
                  _paragraph('For a wager to have action on any named contestant in a Yes/No Proposition, the contestant must enter and compete in the event.'),
                  _paragraph(
                      'We attempt to follow the normal conventions to indicate home and away teams by indicating the home and away team by means of vertical placement on the desktop site version. This means in American Sports we would place the home team on the bottom. For Non-US sports, we would indicate the home team on top. In the case of a neutral venue, we attempt to include the letter “N” next to the team names to indicate this. For the Asian and mobile versions, we do not distinguish between European and American Sports. On the Asian and mobile versions of the site, the home team is always listed first. However, we do not guarantee the accuracy of this information and unless there is an official venue change subsequent to bets being placed, all wagers have action.'),
                  _paragraph(
                      'A game/match will have action regardless of the League heading that is associated with the matchup. For example, two teams from the same League are playing in a Cup competition. If the matchup is mistakenly placed in the League offering, the game/match will still have action, as long as the matchup is correct. In other words, a matchup will have action as long as the two teams are correct, and regardless of the League header in which it is placed on our Website.'),
                  _paragraph(
                      'If an event is not played on the same date as announced by the governing body, then all wagers on the event have no action. If an event is posted by us, with an incorrect date, all wagers have action based on the date announced by the governing body.'),
                  _paragraph('6Ball.com reserves the right to remove events, markets and any other product from the website.'),
                  _paragraph('6Ball.com reserves the right to restrict the casino access of any player without prior notice.'),
                  _paragraph(
                      'In all futures wagering (for example, total season wins, Super Bowl winner, etc.), the winner as determined by the Governing Body will also be declared the winner for betting purposes except when the minimum number of games required for the future to have “action” has not been completed.'),
                  _sectionTitle('11. Communications and Notices'),
                  _paragraph('All communications and notices to be given under these terms by you to us shall be sent to support@6Ball.com'),
                  _paragraph(
                      'All communications and notices to be given under these terms by us to you shall, unless otherwise specified in these terms, be either posted on the Website and/or sent to the Registered Email Address we hold on our system for the relevant Customer. The method of such communication shall be in our sole and exclusive discretion.'),
                  _paragraph(
                      'All communications and notices to be given under these terms by either you or us shall be in writing in the English language when the service is not operated by 6Ball.com , and must be given to and from the Registered Email Address in your Account.'),
                  _sectionTitle('12. Matters Beyond Our Control'),
                  _paragraph(
                      'We cannot be held liable for any failure or delay in providing the service due to an event of Force Majeure which could reasonably be considered to be outside our control despite our execution of reasonable preventative measures such as: an act of God; trade or labour dispute; power cut; act, failure or omission of any government or authority; obstruction or failure of telecommunication services; or any other delay or failure caused by a third party, and we will not be liable for any resulting loss or damage that you may suffer. In such an event, we reserve the right to cancel or suspend the Service without incurring any liability.'),
                  _sectionTitle('13. Liability'),
                  _paragraph(
                      'TO THE EXTENT PERMITTED BY APPLICABLE LAW, WE WILL NOT COMPENSATE YOU FOR ANY REASONABLY FORESEEABLE LOSS OR DAMAGE (EITHER DIRECT OR INDIRECT) YOU MAY SUFFER IF WE FAIL TO CARRY OUT OUR OBLIGATIONS UNDER THESE TERMS UNLESS WE BREACH ANY DUTIES IMPOSED ON US BY LAW (INCLUDING IF WE CAUSE DEATH OR PERSONAL INJURY BY OUR NEGLIGENCE) IN WHICH CASE WE SHALL NOT BE LIABLE TO YOU IF THAT FAILURE IS ATTRIBUTED TO'),
                  _bullet('(I) YOUR OWN FAULT;'),
                  _bullet(
                      '(II) A THIRD PARTY UNCONNECTED WITH OUR PERFORMANCE OF THESE TERMS (FOR INSTANCE PROBLEMS DUE TO COMMUNICATIONS NETWORK PERFORMANCE, CONGESTION, AND CONNECTIVITY OR THE PERFORMANCE OF YOUR COMPUTER EQUIPMENT); OR'),
                  _bullet(
                      '(III) ANY OTHER EVENTS WHICH NEITHER WE NOR OUR SUPPLIERS COULD HAVE FORESEEN OR FORESTALLED EVEN IF WE OR THEY HAD TAKEN REASONABLE CARE. AS THIS SERVICE IS FOR CONSUMER USE ONLY WE WILL NOT BE LIABLE FOR ANY BUSINESS LOSSES OF ANY KIND.'),
                  _paragraph(
                      'IN THE EVENT THAT WE ARE HELD LIABLE FOR ANY EVENT UNDER THESE TERMS, OUR TOTAL AGGREGATE LIABILITY TO YOU UNDER OR IN CONNECTION WITH THESE TERMS SHALL NOT EXCEED'),
                  _bullet(
                      '(A) THE VALUE OF THE BETS AND OR WAGERS YOU PLACED VIA YOUR ACCOUNT IN RESPECT OF THE RELEVANT BET/WAGER OR PRODUCT THAT GAVE RISE TO THE RELEVANT LIABILITY, OR'),
                  _bullet('(B) EUR €500 IN AGGREGATE, WHICHEVER IS LOWER.'),
                  _paragraph(
                      'WE STRONGLY RECOMMEND THAT YOU (I) TAKE CARE TO VERIFY THE SUITABILITY AND COMPATIBILITY OF THE SERVICE WITH YOUR OWN COMPUTER EQUIPMENT PRIOR TO USE; AND (II) TAKE REASONABLE PRECAUTIONS TO PROTECT YOURSELF AGAINST HARMFUL PROGRAMS OR DEVICES INCLUDING THROUGH INSTALLATION OF ANTI-VIRUS SOFTWARE.'),
                  _sectionTitle('14. Gambling By Those Under Age'),
                  _paragraph(
                      'If we suspect that you are or receive notification that you are currently under 18 years or were under 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you) when you placed any bets through the service your account will be suspended to prevent you placing any further bets or making any withdrawals from your account. We will then investigate the matter, including whether you have been betting as an agent for, or otherwise on behalf, of a person under 18 years (or below the age of majority as stipulated in the laws of the jurisdiction applicable to you). If having found that you: (a) are currently; (b) were under 18 years or below the majority age which applies to you at the relevant time; or (c) have been betting as an agent for or at the behest of a person under 18 years or below the majority age which applies:</p>'),
                  _bullet('all winnings currently or due to be credited to your account will be retained;'),
                  _bullet(
                      'all winnings gained from betting through the service whilst under age must be paid to us on demand (if you fail to comply with this provision we will seek to recover all costs associated with recovery of such sums); and/or'),
                  _bullet('any monies deposited in your 6Ball.com account which are not winnings will be returned to you.'),
                  _paragraph(
                      'This condition also applies to you if you are over the age of 18 years but you are placing your bets within a jurisdiction which specifies a higher age than 18 years for legal betting and you are below that legal minimum age in that jurisdiction.'),
                  _paragraph(
                      'In the event we suspect you are in breach of the provisions of this Clause 15 or are attempting to rely on them for a fraudulent purpose, we reserve the right to take any action necessary in order to investigate the matter, including informing the relevant law enforcement agencies.'),
                  _sectionTitle('15. Fraud'),
                  _paragraph(
                      'We will seek criminal and contractual sanctions against any Customer involved in fraud, dishonesty or criminal acts. We will withhold payment to any Customer where any of these are suspected. The Customer shall indemnify and shall be liable to pay to us on demand, all costs, charges or losses sustained or incurred by us (including any direct, indirect or consequential losses, loss of profit, loss of business and loss of reputation) arising directly or indirectly from the Customer’s fraud, dishonesty or criminal act.'),
                  _sectionTitle('16. Intellectual Property'),
                  _paragraph(
                      'We trade as 6Ball.com and the 6Ball.com name and logo are registered trademarks. Any unauthorised use of our trademark and logo may result in legal action being taken against you.'),
                  _paragraph(
                      'The https://www.6Ball.art/ uniform resource locator (URL) is owned by us and no unauthorised use of the URL is permitted on another website or digital platform without our prior written consent.'),
                  _paragraph(
                      'As between us and you, we are the sole owners of the rights in and to the Service, our technology, software and business systems (the “Systems”) as well as our odds.'),
                  _bullet('you must not use your personal profile for your own commercial gain (such as selling your status update to an advertiser); and'),
                  _bullet('when selecting a nickname for your Account we reserve the right to remove or reclaim it if we believe it appropriate.'),
                  _paragraph(
                      'You may not use our URL, trademarks, trade names and/or trade dress, logos (the “Marks”) and/or our odds in connection with any product or service that is not ours, that in any manner is likely to cause confusion among Customers or in the public or that in any manner disparages us.'),
                  _paragraph(
                      'Except as expressly provided in these Terms, we and our licensors do not grant you any express or implied rights, licence, title or interest in or to the Systems or the Marks and all such rights, licence, title and interest specifically retained by us and our licensors. You agree not to use any automatic or manual device to monitor or copy web pages or content within the Service. Any unauthorised use or reproduction may result in legal action being taken against you.'),
                  _paragraph(
                      'Any non-compliance by you with this Clause may also be a violation of our or third parties’ intellectual property and other proprietary rights which may subject you to civil liability and/or criminal prosecution.'),
                  _sectionTitle('17. Your Licence'),
                  _paragraph(
                      'Subject to these terms and your compliance with them, we grant to you a non-exclusive, limited, non transferable and non sub-licensable licence to access and use the Service for your personal non-commercial purposes only. Our licence to you terminates if our agreement with you under these Terms ends.'),
                  _paragraph(
                      'Save in respect of your own content, you may not under any circumstances modify, publish, transmit, transfer, sell, reproduce, upload, post, distribute, perform, display, create derivative works from, or in any other manner exploit, the service and/or any of the content thereon or the software contained therein, except as we expressly permit in these terms or otherwise on the website. No information or content on the service or made available to you in connection with the Service may be modified or altered, merged with other data or published in any form including for example screen or database scraping and any other activity intended to collect, store, reorganise or manipulate such information or content.'),
                  _paragraph(
                      'Any non-compliance by you with this Clause may also be a violation of our or third parties’ intellectual property and other proprietary rights which may subject you to civil liability and/or criminal prosecution.'),
                  _sectionTitle('18. Your Conduct and Safety'),
                  _paragraph(
                      'We would like you to enjoy the Service. However, for your protection and that of all Customers, the posting of any content on the service, as well as conduct in connection therewith and/or the service, which is in any way unlawful, inappropriate or undesirable is strictly prohibited - it is Prohibited Behaviour. If you engage in Prohibited Behaviour, or we determine in our sole discretion that you are engaging in Prohibited Behaviour, your 6Ball.com Account and/or your access to or use of the Service may be terminated immediately without notice to you.'),
                  _paragraph(
                      'Legal action may be taken against you by another Customer, other third party, enforcement authorities and/or us with respect to you having engaged in Prohibited Behaviour.'),
                  _paragraph('Prohibited Behaviour includes, but is not limited to, accessing or using the Service to:'),
                  _bullet('promote or share information that you know is false, misleading or unlawful;'),
                  _bullet(
                      'conduct any unlawful or illegal activity, such as, but not limited to, any activity that furthers or promotes any criminal activity or enterprise, provides instructional information about making or buying weapons, violates another Customer’s or any other third party’s privacy or other rights or that creates or spreads computer viruses;'),
                  _bullet('harm minors in any way;'),
                  _bullet(
                      'transmit or make available any content that is unlawful, harmful, threatening, abusive, tortuous, defamatory, vulgar, obscene, lewd, violent, hateful, or racially or ethnically or otherwise objectionable;'),
                  _bullet(
                      'transmit or make available any content that the user does not have a right to make available under any law or contractual or fiduciary relationship, including without limitation, any content that infringes a third party’s copyright, trademark or other intellectual property and proprietary rights;'),
                  _bullet(
                      'transmit or make available any content or material that contains any software virus or other computer or programming code (including HTML) designed to interrupt, destroy or alter the functionality of the Service, its presentation or any other website, computer software or hardware;'),
                  _bullet(
                      'interfere with, disrupt or reverse engineer the Service in any manner, including, without limitation, intercepting, emulating or redirecting the communication protocols used by us, creating or using cheats, mods or hacks or any other software designed to modify the Service, or using any software that intercepts or collects information from or through the Service;'),
                  _bullet('retrieve or index any information from the Service using any robot, spider or other automated mechanism;'),
                  _bullet(
                      'participate in any activity or action that, in the sole and entire unfettered discretion of us results or may result in another Customer being defrauded or scammed;'),
                  _bullet(
                      'transmit or make available any unsolicited or unauthorised advertising or mass mailing such as, but not limited to, junk mail, instant messaging, "spim", "spam", chain letters, pyramid schemes or other forms of solicitations;'),
                  _bullet('create 6Ball.com Accounts by automated means or under false or fraudulent pretences;'),
                  _bullet('impersonate another Customer or any other third party; or'),
                  _bullet('any other act or thing done that we reasonably consider to be contrary to our business principles.'),
                  _paragraph(
                      'The above list of Prohibited Behaviour is not exhaustive and may be modified by us at any time or from time to time. If you become aware of the misuse of the service by another Customer or any other person, please contact us through the “Contact Us” section of the Website. We reserve the right to investigate and to take all such actions as we in our sole discretion deems appropriate or necessary under the circumstances, including without limitation, deleting the Customer’s posting(s) from the Service and/or terminating their account, and take any action against any Customer or third party who directly or indirectly in, or knowingly permits any third party to directly or indirectly engage in, Prohibited Behaviour, with or without notice to such Customer or third party.'),
                  _sectionTitle('19. Links to Other Websites'),
                  _paragraph(
                      'The Service may contain links to third party websites that are not maintained by, or related to, us, and over which we have no control. Links to such websites are provided solely as a convenience to Customers, and are in no way investigated, monitored or checked for accuracy or completeness by us. Links to such websites do not imply any endorsement by us of, and/or any affiliation with, the linked websites or their content or their owner(s). We have no control over or responsibility for the availability nor their accuracy, completeness, accessibility and usefulness. Accordingly when accessing such websites we recommend that you should take the usual precautions when visiting a new website including reviewing their privacy policy and terms of use.'),
                  _sectionTitle('20. Complaints'),
                  _paragraph('If you have any concerns or questions regarding these terms you should contact our Customer Service Department via email at support@6Ball.com.'),
                  _paragraph(
                      'NOTWITHSTANDING THE FOREGOING, WE TAKE NO LIABILITY WHATSOEVER TO YOU OR TO ANY THIRD PARTY WHEN RESPONDING TO ANY COMPLAINT THAT WE RECEIVED OR TOOK ACTION IN CONNECTION THEREWITH.'),
                  _paragraph(
                      'Any Customer of the Service who has any concerns or questions regarding these Terms regarding the settlement of any 6Ball.com market should contact our Customer Service Department at support@6Ball.com using their Registered Email Address.'),
                  _paragraph(
                      'If a Customer is not satisfied with how a bet has been settled then the Customer should provide details of their grievance to our Customer Service Department via email at support@6Ball.com We shall use our reasonable endeavours to respond to queries of this nature within a few days (and in any event we intend to respond to all such queries within 28 days of receipt).'),
                  _paragraph(
                      'Disputes must be lodged within three (3) days from the date the wager in question has been decided. No claims will be honored after this period. The Customer is solely responsible for their Account transactions. Complaints/disputes have to be sent to support@6Ball.com and must be sent from the Customer’s Registered Email Address.'),
                  _paragraph(
                      'In the event of a dispute arising between you and us our Customer Service Department will attempt to reach an agreed solution. Should our Customer Service Department be unable to reach an agreed solution with you, the matter will be escalated to our management in accordance with our Complaints Procedure (available upon request).'),
                  _paragraph(
                      'The Customer has the right to lodge a complaint with one of our licensing bodies should all efforts to resolve a dispute to the Customer’s satisfaction have failed.'),
                  _sectionTitle('21. Registration and Account Security'),
                  _paragraph(
                      'Customers of the service must provide their real names and information and, in order to comply with this, all Customers must commit to the following rules when registering & maintaining your Account:'),
                  _bullet('you must not provide any false personal information on the Service, or create an Account for anyone other than yourself;'),
                  _bullet('you must not use your personal profile for your own commercial gain (such as selling your status update to an advertiser); and'),
                  _bullet('when selecting a nickname for your Account we reserve the right to remove or reclaim it if we believe appropriate.'),
                  _sectionTitle('22. Assignment'),
                  _paragraph(
                      'Neither these terms nor any of the rights or obligations hereunder may be assigned by you without the prior written consent of us, which consent will not be unreasonably withheld. We may, without your consent, assign all or any portion of our rights and obligations hereunder to any third party provided such third party is able to provide a service of substantially similar quality to the Service by posting written notice to this effect on the Service.'),
                  _sectionTitle('23. Severability'),
                  _paragraph(
                      'In the event that any provision of these terms is deemed by any competent authority to be unenforceable or invalid, the relevant provision shall be modified to allow it to be enforced in line with the intention of the original text to the fullest extent permitted by applicable law. The validity and enforceability of the remaining provisions of these terms shall not be affected.'),
                  _sectionTitle('24. Breach of These Terms'),
                  _paragraph(
                      'Without limiting our other remedies, we may suspend or terminate your account and refuse to continue to provide you with the service, in either case without giving you prior notice, if, in our reasonable opinion, you breach any material term of these Terms. Notice of any such action taken will, however, be promptly provided to you.'),
                  _sectionTitle('25. Governing Law and Jurisdiction'),
                  _paragraph(
                      'This Agreement shall in all respects be governed, interpreted by, and construed in accordance with the laws of Curacao. All disputes, differences, complaints etc., shall be subject to Arbitration under the Curacao. The arbitrator will be appointed by the company after due consent from the company and the user. The place of arbitration shall be Curacao.'),
                  _sectionTitle('26. General Provisions'),
                  _paragraph(
                      'Term of agreement. These terms shall remain in full force and effect while you access or use the service or are a Customer of 6Ball.com. These terms will survive the termination of your 6Ball.com Account for any reason.'),
                  _paragraph(
                      'Gender. Words importing the singular number shall include the plural and vice versa, words importing the masculine gender shall include the feminine and neuter genders and vice versa and words importing persons shall include individuals, partnerships, associations, trusts, unincorporated organisations and corporations.'),
                  _paragraph(
                      'Waiver. No waiver by us, whether by conduct or otherwise, of a breach or threatened breach by you of any term or condition of these Terms shall be effective against, or binding upon, us unless made in writing and duly signed by us, and, unless otherwise provided in the written waiver, shall be limited to the specific breach waived. The failure of us to enforce at any time any term or condition of these Terms shall not be construed to be a waiver of such provision or of the right of us to enforce such provision at any other time.'),
                  _paragraph(
                      'Headings. The division of these Terms into paragraphs and sub-paragraphs and the insertion of headings are for convenience of reference only, and shall not affect or be utilised in the construction or interpretation of these Terms agreement. The terms "these Terms", "hereof", “hereunder” and similar expressions refer to these Terms and not to any particular paragraph or sub-paragraph or other portion hereof and include any agreement supplemental hereto. Unless the subject matter or context is inconsistent therewith, references herein to paragraphs and sub-paragraphs are to paragraphs and sub-paragraphs of these Terms.'),
                  _paragraph(
                      'Acknowledgement. By hereafter accessing or using the Service, you acknowledge having read, understood and agreed to each and every paragraph of these Terms. As a result, you hereby irrevocably waive any future argument, claim, demand or proceeding to the contrary of anything contained in these Terms.'),
                  _paragraph(
                      'Language. In the event of there being a discrepancy between the English language version of these rules and any other language version, the English language version will be deemed to be correct.'),
                  _paragraph(
                      'Entire agreement. These Terms constitute the entire agreement between you and us with respect to your access to and use of the Service, and supersedes all other prior agreements and communications, whether oral or written with respect to the subject matter hereof.'),
                  _sectionTitle('Betting Rules'),
                  _paragraph('Any dispute related to the sports betting product shall be emailed to: support@6Ball.com'),
                  _sectionTitle('Casino Rules'),
                  _paragraph('Any dispute related to the casino product shall be emailed to: support@6Ball.com'),
                  _paragraph('Complete casino rules can be accessed from within the casino games.'),
                  _sectionTitle('ACCEPTING THE TERMS AND CONDITIONS'),
                  _paragraph('You hereby accept the fact that you have read, understood and are willing to abide by the above Terms and Conditions.'),
                  _sectionTitle('Casino Payout restrictions'),
                  _bullet('Restriction of payout is applicable for all Casino games'),
                  _bullet(
                      'In Single round, User is eligible for a max payout of 100 times his bet amount, example if the bet is 100 then max payout shall be 100 X 100 = 10000, any winning above this multiplier shall not be paid out by the company.'),
                  _bullet(
                      'Another restriction is max payout amount is capped at 2,00,00,000 (2 Crore points) , if net winning amount is beyond this amount then user shall be paid only this amount as max winning in Casino games.'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
