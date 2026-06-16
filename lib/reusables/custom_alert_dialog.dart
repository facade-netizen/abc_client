import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/snack_bar.dart';
import '../services/navigators.dart';

class CustomTitleWithCloseButton extends StatelessWidget {
  const CustomTitleWithCloseButton({
    super.key,
    this.isProcessing,
    required this.title,
  });
  final String title;
  final bool? isProcessing;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: bottomBarGradient,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                if (isProcessing == true) {
                  showSnackBar(context, "Please wait for previous action to complete", error: true);
                } else {
                  removeScreen(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                child: Icon(Icons.close, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.actions,
    this.isProcessing,
    required this.title,
    required this.content,
    this.contentPadding,
  });
  final String title;
  final Widget content;
  final bool? isProcessing;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      backgroundColor: Color(0xFFE4E4E4),
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: CustomTitleWithCloseButton(title: title, isProcessing: isProcessing),
      contentPadding: contentPadding,
      content: content,
      actions: isProcessing == true ? [] : actions,
    );
  }
}
