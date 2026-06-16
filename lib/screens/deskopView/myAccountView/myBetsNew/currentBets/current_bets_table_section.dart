import 'package:flutter/material.dart';

import '../../../../../models/open_order_model.dart';
import '../../../../../models/player_bet_history_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/highlighted_text_widget.dart';

const int _marketFlex = 4;
const int _selectionFlex = 2;
const int _typeFlex = 1;
const int _betIdFlex = 2;
const int _betPlacedFlex = 2;
const int _oddsReqFlex = 2;
const int _matchedFlex = 2;
const int _avgOrUnmatchedFlex = 3;
const int _dateMatchedFlex = 2;

class CurrentBetsTableSection extends StatelessWidget {
  const CurrentBetsTableSection({
    super.key,
    required this.title,
    required this.orders,
    required this.matchedTable,
  });

  final String title;
  final List<OpenOrder> orders;
  final bool matchedTable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CurrentBetsSectionHeader(title: title),
        CurrentBetsTableHeader(matchedTable: matchedTable),
        if (orders.isEmpty)
          const CurrentBetsEmptyRow()
        else
          Column(
            children: orders
                .map(
                  (order) => CurrentBetsTableRow(
                    order: order,
                    matchedTable: matchedTable,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class CurrentBetsSectionHeader extends StatelessWidget {
  const CurrentBetsSectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    // Each section gets its own title bar so Matched and Unmatched stay visually separate.
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: tileOrFontColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: HighlightText(
        title,
        style: const TextStyle(
          color: white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class CurrentBetsTableHeader extends StatelessWidget {
  const CurrentBetsTableHeader({
    super.key,
    required this.matchedTable,
  });

  final bool matchedTable;

  @override
  Widget build(BuildContext context) {
    // Header text changes slightly depending on whether this is the matched or unmatched table.
    return Container(
      decoration: const BoxDecoration(
        color: headerRowColor,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          const Expanded(flex: _marketFlex, child: CurrentBetsHeaderCell(title: 'Market', alignRight: false)),
          const Expanded(flex: _selectionFlex, child: CurrentBetsHeaderCell(title: 'Selection')),
          const Expanded(flex: _typeFlex, child: CurrentBetsHeaderCell(title: 'Type')),
          const Expanded(flex: _betIdFlex, child: CurrentBetsHeaderCell(title: 'Bet ID')),
          const Expanded(flex: _betPlacedFlex, child: CurrentBetsHeaderCell(title: 'Bet placed')),
          const Expanded(flex: _oddsReqFlex, child: CurrentBetsHeaderCell(title: 'Odds req.')),
          const Expanded(flex: _matchedFlex, child: CurrentBetsHeaderCell(title: 'Matched')),
          Expanded(
            flex: _avgOrUnmatchedFlex,
            child: CurrentBetsHeaderCell(
              title: matchedTable ? 'Avg. odds matched' : 'Unmatched',
            ),
          ),
          const Expanded(
            flex: _dateMatchedFlex,
            child: CurrentBetsHeaderCell(title: 'Date matched'),
          ),
        ],
      ),
    );
  }
}

class CurrentBetsHeaderCell extends StatelessWidget {
  const CurrentBetsHeaderCell({
    super.key,
    required this.title,
    this.alignRight = true,
  });

  final String title;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: HighlightText(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: headerTextColor,
        ),
      ),
    );
  }
}

class CurrentBetsTableRow extends StatelessWidget {
  const CurrentBetsTableRow({
    super.key,
    required this.order,
    required this.matchedTable,
  });

  final OpenOrder order;
  final bool matchedTable;

  @override
  Widget build(BuildContext context) {
    final String placed = formatDateString(order.timeStamp);
    final String matched = formattedAmounts(order.stake);
    // Unmatched amount is derived from the remaining stake when the order is not fully filled.
    final String unmatched = formattedAmounts((order.stake - (order.filledPrice > 0 ? order.stake : 0)).clamp(0, order.stake));
    final bool isBack = order.side.toLowerCase().contains('back');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: _marketFlex,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: HighlightText.rich(
                  "",
                  textSpan: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                    children: [
                      TextSpan(text: order.sportName),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                      ),
                      TextSpan(
                        text: order.eventName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                      ),
                      TextSpan(text: bettingTypeName(order.bettingType)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _selectionFlex,
              child: CurrentBetsRowCell(
                title: order.bettingType == BettingType.line ? order.marketName : order.runnerName,
              ),
            ),
            Expanded(
              flex: _typeFlex,
              child: CurrentBetsRowCell(
                // Fancy/line bets use Yes/No, while other bet types keep Back/Lay labels.
                title: order.bettingType == BettingType.line ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay'),
                color: isBack ? backType : layType,
              ),
            ),
            Expanded(
              flex: _betIdFlex,
              child: CurrentBetsRowCell(
                color: blue,
                title: order.orderId.toString(),
              ),
            ),
            Expanded(
              flex: _betPlacedFlex,
              child: CurrentBetsRowCell(
                title: placed,
              ),
            ),
            Expanded(
              flex: _oddsReqFlex,
              child: CurrentBetsRowCell(
                title: order.bettingType == BettingType.line ? '${order.line}/${order.price}' : formattedAmounts(order.price),
              ),
            ),
            Expanded(
              flex: _matchedFlex,
              child: CurrentBetsRowCell(
                title: matched,
              ),
            ),
            Expanded(
              flex: _avgOrUnmatchedFlex,
              child: CurrentBetsRowCell(
                title: matchedTable ? formattedAmounts(order.filledPrice) : unmatched,
              ),
            ),
            Expanded(
              flex: _dateMatchedFlex,
              child: CurrentBetsRowCell(
                title: placed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentBetsRowCell extends StatelessWidget {
  const CurrentBetsRowCell({
    super.key,
    required this.title,
    this.alignRight = true,
    this.color,
  });

  final String title;
  final bool alignRight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: HighlightText(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          color: color ?? black,
        ),
      ),
    );
  }
}

class CurrentBetsEmptyRow extends StatelessWidget {
  const CurrentBetsEmptyRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep an inline empty state so the table layout remains consistent when no rows match.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: const BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: const HighlightText(
        'You have no bets in this time period.',
        style: TextStyle(fontSize: 16, color: black),
      ),
    );
  }
}
