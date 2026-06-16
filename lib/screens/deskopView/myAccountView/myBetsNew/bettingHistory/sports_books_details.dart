import 'package:flutter/material.dart';

import '../../../../../models/sportsbook_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';

/// Header config for expanded details
class SBDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(SportsBookModel bet) valueGetter;

  const SBDetailsHeader({
    required this.label,
    this.flex = 1,
    required this.valueGetter,
    this.alignRight = true,
  });
}

List<SBDetailsHeader> bettingDetailsHeaders = [
  SBDetailsHeader(
    label: 'Bet ID',
    valueGetter: (bet) => bet.id.toString(),
  ),
  SBDetailsHeader(
    label: 'Selection',
    valueGetter: (bet) => bet.marketName,
  ),
  SBDetailsHeader(
    label: 'Odds',
    valueGetter: (bet) => formattedAmounts(bet.odds),
  ),
  SBDetailsHeader(
    label: 'Stake',
    valueGetter: (bet) => formattedAmounts(bet.debitAmount),
  ),
  SBDetailsHeader(
    label: 'Type',
    valueGetter: (bet) => bet.requestType,
  ),
  SBDetailsHeader(
    label: 'Placed',
    valueGetter: (bet) => formatDateString(bet.createdDate),
  ),
];

class SportsBookDetails extends StatelessWidget {
  const SportsBookDetails({super.key, required this.bet});
  final SportsBookModel bet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double leftSpacerWidth = availableWidth * 0.3;
        final double detailsWidth = (availableWidth - leftSpacerWidth - 2).clamp(0.0, double.infinity);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFe0e9ee),
            border: Border(
              top: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: leftSpacerWidth),
                VerticalDivider(
                  color: borderColor,
                  width: 2,
                ),
                SizedBox(
                  width: detailsWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: bettingDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: SelectableText(
                                    header.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: headerTextColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Data Row
                      Container(
                        height: 30,
                        color: const Color(0xFFF2F4F7),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: bettingDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: SelectableText(
                                    header.valueGetter(bet),
                                    style: const TextStyle(fontSize: 12, color: black, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
