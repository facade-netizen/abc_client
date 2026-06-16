import 'package:flutter/material.dart';

import '../../../models/competation_with_events_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../openBetsView/bets_tab_item.dart';

class SportsHeader extends StatelessWidget {
  const SportsHeader({
    super.key,
    this.child,
    this.title,
    this.height,
    this.color,
  });
  final String? title;
  final double? height;
  final Color? color;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: height ?? 30,
      width: size.width,
      color: color ?? black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: child != null,
            child: SizedBox(child: child),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(title ?? "Sports", style: TextStyle(color: white)),
          ),
        ],
      ),
    );
  }
}

class SportsMenuTile extends StatefulWidget {
  const SportsMenuTile({
    super.key,
    required this.event,
    required this.selectedEvent,
    this.action,
  });

  final void Function()? action;
  final Competition event;
  final String selectedEvent;

  @override
  State<SportsMenuTile> createState() => _SportsMenuTileState();
}

class _SportsMenuTileState extends State<SportsMenuTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.action,
        child: Container(
          height: 30,
          width: size.width,
          decoration: BoxDecoration(
            color: widget.selectedEvent == widget.event.name
                ? whiteOpac1
                : isHovered
                    ? highlightHeader.withValues(alpha: 0.1)
                    : white,
            border: Border(
              bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.event.name,
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.normal,
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class SportsBetSlip extends StatelessWidget {
  const SportsBetSlip({super.key});

  @override
  Widget build(BuildContext context) {
    return BetsSlipTab(
      child: Container(
        color: white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hb20,
            Center(
              child: Text(
                "Click on the odds to add selections to the betslip.",
                style: TextStyle(color: black, fontSize: 13, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SportsEventMenu extends StatelessWidget {
  const SportsEventMenu({
    super.key,
    this.itemCount,
    this.title,
    required this.itemBuilder,
  });
  final String? title;
  final int? itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportsHeader(title: title),
          Expanded(
            child: ListView.builder(itemCount: itemCount, itemBuilder: itemBuilder),
          ),
        ],
      ),
    );
  }
}

class SportsBannerCard extends StatelessWidget {
  const SportsBannerCard({super.key, required this.image});
  final String image;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Visibility(
      visible: image.isNotEmpty,
      child: Image.asset(
        image,
        height: 200,
        width: size.width,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
