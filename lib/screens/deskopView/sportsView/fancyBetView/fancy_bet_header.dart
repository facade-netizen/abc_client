import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../models/fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/style.dart';
import '../matchOddsView/match_odds_header.dart';

class FancyPremiumBetHeader extends StatelessWidget {
  const FancyPremiumBetHeader({
    super.key,
    this.onTapInfo,
    this.toggleExpand,
    this.isExpanded = false,
    required this.isFancyBet,
  });
  final bool isFancyBet;
  final void Function()? onTapInfo;
  final void Function()? toggleExpand;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: isFancyBet ? fancyGradient : premiumGradient,
            borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
            border: Border(bottom: BorderSide(color: isFancyBet ? fancy : premiumColor, width: 1)),
          ),
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 25,
                  margin: EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: green,
                  ),
                  child: Center(child: Icon(Icons.alarm, color: white, size: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: HighlightText(isFancyBet ? "Fancy Bet" : "Premium Fancy Bet", style: TextStyle(color: white)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: onTapInfo,
                    child: Icon(Icons.info, color: whiteOpac, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (toggleExpand != null)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: toggleExpand,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      color: white,
                      size: 17,
                    ),
                  ),
                ),
              )
            ],
          ),
      ],
    );
  }
}

class FancyBetHeader extends StatelessWidget {
  const FancyBetHeader({
    super.key,
    this.gradient,
    this.title,
    this.onTapInfo,
    this.toggleExpand,
    this.isExpanded = false,
  });
  final Gradient? gradient;
  final String? title;
  final void Function()? onTapInfo;
  final void Function()? toggleExpand;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: gradient ?? fancyGradient,
            borderRadius: BorderRadius.only(topRight: Radius.circular(15)),
          ),
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 25,
                  margin: EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: green,
                  ),
                  child: Center(child: Icon(Icons.alarm, color: white, size: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: HighlightText(title ?? "Fancy Bet", style: TextStyle(color: white)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: onTapInfo,
                    child: Icon(Icons.info, color: whiteOpac, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: toggleExpand,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: white,
                    size: 15,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class BetTabTile extends StatelessWidget {
  const BetTabTile({
    super.key,
    this.action,
    required this.title,
    required this.selectedTab,
    this.color,
  });
  final Color? color;
  final String title;
  final String selectedTab;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedTab.replaceAll('_', ' ').toUpperCase() == title.replaceAll('_', ' ').toUpperCase();
    return InkWell(
      onTap: action,
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? white : none,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            title.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? (color ?? fancy) : white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class SportsBetHeader extends StatelessWidget {
  const SportsBetHeader({
    super.key,
    this.child,
    this.color,
    this.leading,
    required this.title,
    this.action,
    this.toggleExpand,
    this.isExpanded = false,
  });
  final String title;
  final Color? color;
  final Widget? child;
  final Widget? leading;
  final bool isExpanded;
  final void Function()? action;
  final void Function()? toggleExpand;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      color: color ?? darkGreen,
      child: InkWell(
        onTap: action == null
            ? null
            : () {
                action!();
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: leading,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: HighlightText(
                    title,
                    style: TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(child: child),
              ],
            ),
            if (toggleExpand != null)
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(
                  child: InkWell(
                    onTap: toggleExpand,
                    child: Icon(
                      isExpanded ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                      size: 18,
                      color: white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class YesNoTileHeader extends StatelessWidget {
  const YesNoTileHeader({super.key});
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

class FancyMmInfo extends StatelessWidget {
  const FancyMmInfo({
    super.key,
    required this.bet,
  });
  final FancyMarketData bet;
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

class FancyBetName extends StatelessWidget {
  const FancyBetName({
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
  final FancyMarketData bet;
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

class FBStatus extends StatelessWidget {
  final FancyMarketData market;
  final String backLine1;
  final String layLine1;
  final String backLine2;
  final String layLine2;
  final bool isSecondRow;

  const FBStatus({
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
