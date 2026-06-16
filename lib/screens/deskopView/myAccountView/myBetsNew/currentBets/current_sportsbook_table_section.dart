import 'package:flutter/material.dart';

import '../../../../../models/sportsbook_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/highlighted_text_widget.dart';

const int _marketFlex = 3;
const int _selectionFlex = 2;
const int _typeFlex = 1;
const int _betIdFlex = 2;
const int _betPlacedFlex = 2;
const int _stakeFlex = 2;
const int _oddsReqFlex = 2;
const int _matchedFlex = 2;

class CurrentSBBetsTableSection extends StatelessWidget {
  const CurrentSBBetsTableSection({super.key, required this.title, required this.sportsBookOrders, required this.matchedTable});

  final String title;
  final List<SportsBookModel> sportsBookOrders;
  final bool matchedTable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CurrentBetsSectionHeader(title: title),
        CurrentBetsTableHeader(matchedTable: matchedTable),
        if (sportsBookOrders.isEmpty)
          const CurrentSBBetsEmptyRow()
        else
          Column(
            children: sportsBookOrders.map((order) => CurrentSBBetsTableRow(order: order, matchedTable: matchedTable)).toList(),
          ),
      ],
    );
  }
}

class CurrentBetsSectionHeader extends StatelessWidget {
  const CurrentBetsSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Each section gets its own title bar so Matched and Unmatched stay visually separate.
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: tileOrFontColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: HighlightText(
        title,
        style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class CurrentBetsTableHeader extends StatelessWidget {
  const CurrentBetsTableHeader({super.key, required this.matchedTable});

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
          const Expanded(
            flex: _marketFlex,
            child: CurrentBetsHeaderCell(title: 'Market', alignRight: false),
          ),
          const Expanded(
            flex: _selectionFlex,
            child: CurrentBetsHeaderCell(title: 'Selection'),
          ),
          const Expanded(
            flex: _typeFlex,
            child: CurrentBetsHeaderCell(title: 'Type'),
          ),
          const Expanded(
            flex: _betIdFlex,
            child: CurrentBetsHeaderCell(title: 'Bet ID'),
          ),
          const Expanded(
            flex: _betPlacedFlex,
            child: CurrentBetsHeaderCell(title: 'Bet placed'),
          ),
          const Expanded(
            flex: _stakeFlex,
            child: CurrentBetsHeaderCell(title: 'Stake'),
          ),
          const Expanded(
            flex: _oddsReqFlex,
            child: CurrentBetsHeaderCell(title: 'Odds req.'),
          ),
          const Expanded(
            flex: _matchedFlex,
            child: CurrentBetsHeaderCell(title: 'Avg. odds matched'),
          ),
        ],
      ),
    );
  }
}

class CurrentBetsHeaderCell extends StatelessWidget {
  const CurrentBetsHeaderCell({super.key, required this.title, this.alignRight = true});

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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: headerTextColor),
      ),
    );
  }
}

class CurrentSBBetsTableRow extends StatelessWidget {
  const CurrentSBBetsTableRow({super.key, required this.order, required this.matchedTable});

  final SportsBookModel order;
  final bool matchedTable;

  @override
  Widget build(BuildContext context) {
    final String placed = formatDateString(order.createdDate);
    final bool isBack = order.runnerType.toLowerCase().contains('back');

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
                      TextSpan(text: "S/R"),
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
                      TextSpan(text: order.marketName),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _selectionFlex,
              child: CurrentSBBetsRowCell(title: order.runnerName),
            ),
            Expanded(
              flex: _typeFlex,
              child: CurrentSBBetsRowCell(
                // Fancy/line bets use Yes/No, while other bet types keep Back/Lay labels.
                title: (isBack ? 'Back' : 'Lay'),
                color: isBack ? backType : layType,
              ),
            ),
            Expanded(
              flex: _betIdFlex,
              child: CurrentSBBetsRowCell(color: blue, title: order.id.toString()),
            ),
            Expanded(
              flex: _betPlacedFlex,
              child: CurrentSBBetsRowCell(title: placed),
            ),
            Expanded(
              flex: _stakeFlex,
              child: CurrentSBBetsRowCell(title: order.debitAmount.toStringAsFixed(2)),
            ),
            Expanded(
              flex: _oddsReqFlex,
              child: CurrentSBBetsRowCell(title: order.odds.toStringAsFixed(2)),
            ),
            Expanded(
              flex: _matchedFlex,
              child: CurrentSBBetsRowCell(title: order.odds.toStringAsFixed(2)),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentSBBetsRowCell extends StatelessWidget {
  const CurrentSBBetsRowCell({super.key, required this.title, this.alignRight = true, this.color});

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
        style: TextStyle(fontSize: 13, color: color ?? black),
      ),
    );
  }
}

class CurrentSBBetsEmptyRow extends StatelessWidget {
  const CurrentSBBetsEmptyRow({super.key});

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
      child: const HighlightText('You have no bets in this time period.', style: TextStyle(fontSize: 16, color: black)),
    );
  }
}
