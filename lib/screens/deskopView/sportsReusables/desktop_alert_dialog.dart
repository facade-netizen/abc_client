import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../services/navigators.dart';
import 'custom_cta_button.dart';

class DesktopTitleWithCloseButton extends StatelessWidget {
  const DesktopTitleWithCloseButton({
    super.key,
    this.isProcessing,
    required this.title,
  });
  final String title;
  final bool? isProcessing;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hb8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: darkGreen, fontSize: 20, fontWeight: FontWeight.bold),
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
                    decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.close, color: white),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: darkGreen),
        ],
      ),
    );
  }
}

class DesktopAlertDialog extends StatelessWidget {
  const DesktopAlertDialog({
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
      backgroundColor: white,
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: DesktopTitleWithCloseButton(title: title, isProcessing: isProcessing),
      contentPadding: contentPadding,
      content: content,
      actions: isProcessing == true ? [] : actions,
    );
  }
}

class DesktopADButton extends StatelessWidget {
  const DesktopADButton({super.key, this.width, this.action, this.title, this.showDivider = true});
  final String? title;
  final double? width;
  final bool showDivider;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) Divider(color: darkGreen),
        hb12,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CancelCTAButton(),
            wb10,
            CustomCTAButton(title: title ?? "Save", action: action, width: width, color: appYellow),
            wb10,
          ],
        ),
        hb12,
      ],
    );
  }
}
