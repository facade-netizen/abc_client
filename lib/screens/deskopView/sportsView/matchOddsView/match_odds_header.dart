import 'package:flutter/material.dart';

import '../../../../models/event_with_type_model.dart';
import '../../../../models/odd_data_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/style.dart';

class MatchOddsHeader extends StatelessWidget {
  const MatchOddsHeader({super.key, required this.data, this.onTap, required this.event, this.toggleExpand, this.isExpanded = false});

  final Event event;
  final ODDSData data;
  final void Function()? onTap;
  final bool isExpanded;
  final void Function()? toggleExpand;

  bool isValidNum(num? value) => value != null && value != 0;
  bool isValidString(String? value) => value != null && value.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final minBet = data.marketCondition.minBet;
    final maxBet = data.marketCondition.maxBet;
    return Container(
      height: 50,
      color: white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isValidString(data.marketName))
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5D0D7),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 12),
                    child: Center(
                      child: HighlightText(
                        data.marketName,
                        style: const TextStyle(color: Color(0xFF243A48), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              if (isValidString(data.marketName)) wb10,

              /// Marke Time
              if (event.openDate.isNotEmpty)
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 25,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: event.inPlay ? green : darkGreen),
                      child: const Center(child: Icon(Icons.alarm, color: white, size: 14)),
                    ),
                    Text(formatUtcToLocal(event.openDate), style: TextStyle(color: event.inPlay ? green : darkGreen)),
                  ],
                ),
            ],
          ),

          /// RIGHT SIDE
          if (isValidNum(minBet) || isValidNum(maxBet))
            Container(
              decoration: BoxDecoration(color: Color(0xFFbed5d8), borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    if (isValidNum(minBet))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'Min/Max ',
                          style: const TextStyle(color: Color(0xFF243A48), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (isValidNum(maxBet))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          ' ${formatMinValue(minBet)} / ${formatMinValue(maxBet)}',
                          style: const TextStyle(color: Color(0xFF243A48), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          SizedBox(width: 100),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: toggleExpand,
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(2)),
                    child: Icon(isExpanded ? Icons.remove : Icons.add, color: white, size: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MatchOddsBLHeader extends StatelessWidget {
  const MatchOddsBLHeader({super.key, required this.selections, this.top = 15});
  final String selections;
  final double top;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: HighlightText("$selections selections", style: TextStyle(fontSize: 12, color: applyOpacity(darkGreen, 0.6))),
            ),
            SizedBox(
              width: blw(context) * 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("", textAlign: TextAlign.center, style: n12ts),

                  ///100.8%
                  BackLayCips(),
                ],
              ),
            ),
            SizedBox(
              width: blw(context) * 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackLayCips(type: 2),
                  Text("", textAlign: TextAlign.center, style: n12ts), //99.6%
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackLayCips extends StatelessWidget {
  const BackLayCips({this.type = 1, super.key});
  final int type;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: blw(context),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: type == 1 ? backBtn : layBtn,
        borderRadius: BorderRadius.only(topRight: type == 2 ? Radius.circular(15) : Radius.circular(0), topLeft: type == 1 ? Radius.circular(15) : Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [HighlightText("${type == 1 ? 'Back' : 'Lay'} All", style: n12ts)],
      ),
    );
  }
}

double getBackOpacity(int index) {
  return switch (index) {
    0 => 1.0,
    1 => 0.4,
    _ => 0.2,
  };
}

double getLayOpacity(int index) {
  return switch (index) {
    0 => 1.0,
    1 => 0.4,
    _ => 0.2,
  };
}

double blw(BuildContext context) {
  Size size = MediaQuery.sizeOf(context);
  return size.width * 0.055;
}

class BackLayAllCTAButton extends StatelessWidget {
  const BackLayAllCTAButton({super.key, this.title, this.value, this.action, this.color, this.disabled = false, this.active = false, this.isFlash = false});
  final Color? color;
  final bool disabled;
  final bool active, isFlash;
  final String? title, value;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : action,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 45,
        width: blw(context),
        decoration: BoxDecoration(
          color: color,
          border: Border(right: BorderSide(color: white, width: 0.8)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (disabled) const CustomPaint(painter: DisabledStripePainter()),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HighlightText(title ?? "-", style: b13ts(color: active || isFlash ? white : black)),
                  HighlightText(
                    value ?? "-",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: active || isFlash ? white : black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisabledStripePainter extends CustomPainter {
  const DisabledStripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = Colors.grey.shade400.withOpacity(0.25)
      ..strokeWidth = 1.4;

    final step = 12.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MOStatus extends StatelessWidget {
  const MOStatus({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: blw(context) * 6,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.4)),
      child: Center(
        child: HighlightText(status, style: b13ts(color: white)),
      ),
    );
  }
}
