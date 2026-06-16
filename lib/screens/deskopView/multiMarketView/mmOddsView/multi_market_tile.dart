import 'package:flutter/material.dart';

import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';

class MultiMarketTile extends StatefulWidget {
  const MultiMarketTile({super.key, required this.market, required this.selectedMarket, this.action});
  final String market;
  final String selectedMarket;
  final void Function()? action;

  @override
  State<MultiMarketTile> createState() => _MultiMarketTileState();
}

class _MultiMarketTileState extends State<MultiMarketTile> {
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
            color: widget.selectedMarket == widget.market
                ? whiteOpac1
                : isHovered
                ? highlightHeader.withValues(alpha: 0.1)
                : white,
            border: Border(bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3))),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: HighlightText(
              widget.market,
              style: TextStyle(color: black, fontWeight: FontWeight.normal, fontSize: 13, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
