import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../models/mm_fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/style.dart';
import '../../sportsView/matchOddsView/match_odds_header.dart';

class MmYesNoTileHeader extends StatelessWidget {
  const MmYesNoTileHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: black, width: 0.5)),
      ),
      height: 30,
      child: Row(
        children: [
          Expanded(flex: 2, child: SizedBox()),
          SizedBox(width: blw(context), child: Center(child: Text('No', style: b14ts))),
          SizedBox(width: blw(context), child: Center(child: Text('Yes', style: b14ts))),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class MmFancyMmInfo extends StatelessWidget {
  const MmFancyMmInfo({
    super.key,
    required this.bet,
  });
  final MMFancyMarketData bet;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Min/Max', style: TextStyle(color: applyOpacity(darkGreen, 0.7), fontSize: 12)),
            hb4,
            Text(
              formatMinMaxValues(
                min: bet.marketCondition?.minBet ?? 0,
                max: bet.marketCondition?.maxBet ?? 0,
              ),
              style: const TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class MmFancyBetName extends StatelessWidget {
  const MmFancyBetName({
    super.key,
    required this.bet,
    required this.isActive,
    required this.fancyNetVisible,
    required this.fancyExposure,
    required this.fancyNet,
    this.color,
    required this.showBook,
    this.bookAction,
  });
  final String fancyNet;
  final String fancyExposure;
  final Color? color;
  final MMFancyMarketData bet;
  final bool isActive, showBook, fancyNetVisible;
  final void Function()? bookAction;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HighlightText(bet.marketName, style: b14ts),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: fancyNetVisible,
                      child: HighlightText(
                        fancyNet.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    wb5,
                    if (isActive)
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssetConstants.arrowTo,
                            height: 9,
                            width: 9,
                            colorFilter: ColorFilter.mode(fancyExposure.isEmpty ? green : red, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 5),
                          HighlightText(
                            fancyExposure,
                            style: TextStyle(fontWeight: FontWeight.w700, color: fancyExposure.isEmpty ? green : red, fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Visibility(
              visible: showBook,
              child: InkWell(
                onTap: bookAction,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xffffcc51),
                    border: Border.all(color: black),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: const Center(child: Text("Book", style: TextStyle(color: black))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MmFBStatus extends StatelessWidget {
  final MMFancyMarketData market;
  final String backLine1;
  final String layLine1;
  final String backLine2;
  final String layLine2;
  final bool isSecondRow;

  const MmFBStatus({
    super.key,
    required this.market,
    required this.backLine1,
    required this.layLine1,
    required this.backLine2,
    required this.layLine2,
    this.isSecondRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveStatuses = {
      'SUSPENDED',
      'SUSPEND',
      'INACTIVE',
      'CLOSED',
      'VOID',
      'OFFLINE',
      'VOIDED',
      'SETTLED',
      'BALL_RUN',
      'SETTLE_PROCESSING',
      'VOID_PROCESSING',
    };

    final status = market.status.toUpperCase();

    final backLine = isSecondRow ? backLine2 : backLine1;
    final layLine = isSecondRow ? layLine2 : layLine1;

    final show = inactiveStatuses.contains(status) || market.sportingEvent == true || (backLine.isEmpty && layLine.isEmpty);

    if (!show) return const SizedBox.shrink();

    final text = market.sportingEvent == true || market.status == 'BALL_RUN'
        ? "Ball Running"
        : market.status == 'OFFLINE' || market.status == 'SUSPENDED' || market.status == 'SUSPEND' || (backLine.isEmpty && layLine.isEmpty)
            ? "Suspended"
            : "";
    return Container(
      height: 45,
      width: blw(context) * 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
      child: Center(
        child: Text(text, style: b13ts(color: white)),
      ),
    );
  }
}
