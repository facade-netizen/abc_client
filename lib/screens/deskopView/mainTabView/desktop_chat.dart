import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../../reusables/buttons.dart';
import '../../../reusables/colors.dart';

class ChatOverlay extends StatefulWidget {
  const ChatOverlay({super.key});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  final GlobalKey fabKey = GlobalKey();

  static const String _currentUserId = 'user1';
  static const String _supportUserId = 'support';

  final User _user = const User(id: _currentUserId, name: 'John');
  final User _supportUser = const User(id: _supportUserId, name: '6Ball 365 Support');

  late final InMemoryChatController _chatController = InMemoryChatController(
    messages: [TextMessage(id: '1', authorId: _supportUserId, createdAt: DateTime.now().toUtc(), text: 'Hello! Welcome to 6Ball 365. How can I help you today?')],
  );

  Future<User?> _resolveUser(UserID id) async {
    if (id == _currentUserId) return _user;
    if (id == _supportUserId) return _supportUser;
    return null;
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    overlayEntry = null;
    _chatController.dispose();
    super.dispose();
  }

  void toggleChatOverlay() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);

    // Get FAB position and size
    RenderBox renderBox = fabKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Position chat overlay relative to FAB
            Positioned(
              left: offset.dx - 350 + size.width, // Position to left of FAB
              top: offset.dy - 500, // Position above FAB with 10px gap
              child: Material(
                elevation: 10,
                color: white,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 350, // Fixed width
                  height: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: loginbg,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.chat, color: white),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '6Ball 365 Support',
                                style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: white),
                              onPressed: toggleChatOverlay,
                            ),
                          ],
                        ),
                      ),

                      // Chat area
                      Expanded(
                        child: Chat(
                          currentUserId: _currentUserId,
                          resolveUser: _resolveUser,
                          chatController: _chatController,
                          onMessageSend: handleSendPressed,
                          theme: ChatTheme.light().copyWith(
                            colors: ChatColors.light().copyWith(
                              primary: buttonGreen,
                              onPrimary: white,
                              surface: white,
                              onSurface: black,
                              surfaceContainer: blncNameBox,
                              surfaceContainerLow: white,
                              surfaceContainerHigh: blncNameBox,
                            ),
                          ),
                          backgroundColor: white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry!);
  }

  String _getResponseToQuery(String userMessage) {
    final message = userMessage.toLowerCase();

    // Greetings and common questions
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return 'Hello! Welcome to 6Ball 365 Support. How can I assist you today?';
    }

    if (message.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    }

    if (message.contains('bye') || message.contains('goodbye')) {
      return 'Goodbye! Have a great day. Feel free to reach out if you need further assistance.';
    }

    // Product/Service related queries
    if (message.contains('what is 6Ball 365') || message.contains('6Ball 365')) {
      return '6Ball 365 is a comprehensive business solution offering integrated services for your organization. We provide cloud services, productivity tools, and enterprise solutions.';
    }

    if (message.contains('feature') || message.contains('offer')) {
      return '6Ball 365 offers: Cloud storage, Collaboration tools, Security features, Analytics dashboard, 24/7 support, and Mobile applications.';
    }

    if (message.contains('price') || message.contains('cost') || message.contains('subscription')) {
      return 'We offer flexible pricing plans: Basic ("${9.99}"/month), Pro ("${19.99}"/month), and Enterprise (Custom pricing). All plans include 24/7 support.';
    }

    // Technical support queries
    if (message.contains('login') || message.contains('sign in') || message.contains('password')) {
      return 'For login issues: 1) Reset your password using "Forgot Password" 2) Clear browser cache 3) Try incognito mode 4) Contact admin if issues persist';
    }

    if (message.contains('error') || message.contains('issue') || message.contains('problem')) {
      return 'I\'m sorry you\'re experiencing issues. Can you please describe the error message or what exactly isn\'t working? For immediate help, you can also email support@6Ball365.com';
    }

    if (message.contains('download') || message.contains('install')) {
      return 'You can download 6Ball 365 from our official website or mobile app stores. Make sure your system meets minimum requirements: Windows 10+/macOS 10.14+/Android 8+/iOS 13+';
    }

    if (message.contains('mobile') || message.contains('app') || message.contains('phone')) {
      return 'Yes! 6Ball 365 is available on both iOS and Android. Search "6Ball 365" in your app store. Features may vary slightly between mobile and desktop versions.';
    }

    // Account management
    if (message.contains('account') || message.contains('create account') || message.contains('register')) {
      return 'To create an account: 1) Visit our website 2) Click "Sign Up" 3) Enter your details 4) Verify email 5) Complete setup wizard. Need help? Our team can assist!';
    }

    if (message.contains('cancel') || message.contains('delete') || message.contains('close account')) {
      return 'To cancel your subscription: Go to Account Settings > Billing > Cancel Subscription. Account deletion requests must be emailed to privacy@6Ball365.com with subject: "Account Deletion Request"';
    }

    // Contact information
    if (message.contains('contact') || message.contains('email') || message.contains('phone number') || message.contains('call')) {
      return 'Contact options: Email: support@6Ball365.com\nPhone: 1-800-6Ball-365\nLive Chat: Available 24/7\nOffice Hours: Mon-Fri 9AM-6PM EST';
    }

    if (message.contains('hours') || message.contains('time') || message.contains('available')) {
      return 'Our support team is available 24/7 via chat and email. Phone support: Mon-Fri 9AM-6PM EST. Emergency issues are prioritized.';
    }

    // Default response for unrecognized queries
    return 'Thank you for your message. I understand you\'re asking about "$userMessage". For detailed assistance with this, I recommend:\n1) Checking our Help Center\n2) Emailing support@6Ball365.com\n3) Calling 1-800-6Ball-365\nOur team will provide specific guidance based on your needs.';
  }

  void handleSendPressed(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // First, add only the user's message
    final textMessage = TextMessage(id: Random().nextInt(100000).toString(), authorId: _currentUserId, createdAt: DateTime.now().toUtc(), text: trimmed);

    _chatController.insertMessage(textMessage);

    // Wait for 1 second before showing the response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || overlayEntry == null) return;
      // Get AI response based on user query
      final responseText = _getResponseToQuery(trimmed);

      final responseMessage = TextMessage(id: Random().nextInt(100000).toString(), authorId: _supportUserId, createdAt: DateTime.now().toUtc(), text: responseText);

      _chatController.insertMessage(responseMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: CustomFAB(key: fabKey, onPressed: toggleChatOverlay),
    );
  }
}
