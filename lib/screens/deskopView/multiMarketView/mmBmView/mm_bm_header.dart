import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../models/favourite_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/style.dart';
import '../../sportsView/matchOddsView/match_odds_header.dart';

//double bbw = 100;
double bbh = 50;

class MmBMStatus extends StatelessWidget {
  const MmBMStatus({super.key, this.status});
  final String? status;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: bbh,
      width: (blw(context) + 4) * 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
      child: Center(
        child: Text(status ?? "Suspended", style: b13ts(color: white)),
      ),
    );
  }
}

class MmBmBackLayCTA extends StatelessWidget {
  const MmBmBackLayCTA({super.key, this.price, this.size, this.action, this.color, this.isBack = true, this.active = false, this.isFlash = false});

  final String? price;
  final String? size;
  final bool isBack;
  final bool active;
  final bool isFlash;
  final void Function()? action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Flash color overrides normal color
    final displayColor = color ?? (isBack ? (active ? oddsBackBtn : backBtn) : (active ? pinkButtonClr : layBtn));

    // Text color: white if active or flash, black otherwise
    final textColor = active || isFlash ? white : black;

    return InkWell(
      onTap: action,
      child: Container(
        height: 45,
        width: blw(context),
        decoration: BoxDecoration(
          color: displayColor,
          border: Border.all(color: white),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                child: Text(price ?? "-"),
              ),
              if (size != null)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(color: textColor, fontSize: 11),
                  child: Text(size!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MmBmBetName extends StatelessWidget {
  const MmBmBetName({super.key, required this.bmRunner, this.currentPL, required this.bmNet, required this.bmNetVisible});
  final FavRunner bmRunner;
  final double? currentPL;
  final String bmNet;
  final bool bmNetVisible;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HighlightText(bmRunner.name, style: b14ts),
            Row(
              children: [
                Visibility(
                  visible: bmNetVisible,
                  child: HighlightText(
                    bmNet,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: bmNet.isNotEmpty && (double.tryParse(bmNet) ?? 0.0) > 0 ? green : red, fontWeight: FontWeight.w400),
                  ),
                ),
                if (currentPL != null) ...[
                  const SizedBox(width: 5),
                  Row(
                    children: [
                      SvgPicture.asset(AppAssetConstants.arrowTo, height: 9, width: 9, colorFilter: ColorFilter.mode(currentPL! > 0 ? green : red, BlendMode.srcIn)),
                      const SizedBox(width: 5),
                      HighlightText(
                        currentPL! >= 0 ? currentPL!.toStringAsFixed(2) : "(${currentPL!.abs().toStringAsFixed(2)})",
                        style: TextStyle(fontWeight: FontWeight.w700, color: currentPL! > 0 ? green : red, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MmBmBackLayHeader extends StatelessWidget {
  const MmBmBackLayHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: creamyColor,
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: (blw(context) + 8) * 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text('Back', style: b14ts, textAlign: TextAlign.end),
                ),
              ),
              SizedBox(
                width: (blw(context) + 8) * 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Lay', style: b14ts, textAlign: TextAlign.left),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MmBookmakerMmTile extends StatelessWidget {
  const MmBookmakerMmTile({super.key, this.minBet = 0, this.maxBet = 0});

  final int minBet;
  final int maxBet;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: tileColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Bookmaker", style: TextStyle(color: black)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (minBet > 0) MmMmCard(minBet: minBet, maxBet: maxBet),
                if (maxBet > 0) MmMmCard(min: 2, minBet: minBet, maxBet: maxBet),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MmMmCard extends StatelessWidget {
  const MmMmCard({super.key, this.min = 1, this.minBet = 0, this.maxBet = 0});
  final int min, minBet, maxBet;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(gradient: blueGradient, borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              child: Text(min == 1 ? "Min" : "Max", style: TextStyle(color: white, fontSize: 12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(min == 1 ? formatMinValue(minBet) : formatMinValue(maxBet), style: TextStyle(color: black, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
