import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../reusables/colors.dart';
import '../../reusables/sized_box_hw.dart';
import '../../services/navigators.dart';

void showChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Basic(),
        );
      },
    ),
  );
}

class Basic extends StatefulWidget {
  const Basic({super.key});

  @override
  State<Basic> createState() => _BasicState();
}

class _BasicState extends State<Basic> {
  final List<types.Message> _messages = [];

  final types.User _user = const types.User(
    id: 'user1',
    firstName: 'John',
  );

  void handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      id: Random().nextInt(100000).toString(),
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: grey),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    removeScreen(context);
                  },
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(border: Border.all(color: grey)),
                    child: Center(child: Icon(Icons.arrow_left, color: white, size: 25)),
                  ),
                ),
                wb10,
                Expanded(
                  child: Center(
                    child: Text(
                      "Chat",
                      style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
