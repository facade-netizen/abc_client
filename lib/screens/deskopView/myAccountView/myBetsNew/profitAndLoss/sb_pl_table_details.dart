import 'package:flutter/material.dart';

import '../../../../../models/sportsbook_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/highlighted_text_widget.dart';
import 'exchange_pl_details.dart';

class SBPlTableHeader extends StatelessWidget {
  const SBPlTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 32,
      decoration: const BoxDecoration(
        color: headerRowColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          ExchangeHeaderCell(flex: 4, title: 'Market'),
          ExchangeHeaderCell(flex: 4, title: 'Start Time'),
          ExchangeHeaderCell(flex: 4, title: 'Settled Time'),
          ExchangeHeaderCell(title: 'Profit/Loss'),
        ],
      ),
    );
  }
}

/// Header config for SBPl details
class SBPlDetailsHeader {
  final String label;
  final double flex;
  final bool alignRight;
  final String Function(SportsBookModel report) valueGetter;
  final Color Function(SportsBookModel report)? color;

  const SBPlDetailsHeader({
    required this.label,
    this.flex = 1,
    required this.valueGetter,
    this.alignRight = true,
    this.color,
  });
}

/// Define your details headers dynamically
List<SBPlDetailsHeader> sbPlDetailsHeaders = [
  SBPlDetailsHeader(
    label: 'Bet ID',
    flex: 4,
    alignRight: false,
    valueGetter: (report) => report.id.toString(),
    color: (report) => black,
  ),
  SBPlDetailsHeader(
    label: 'Selection',
    flex: 2,
    valueGetter: (report) => report.marketName,
  ),
  SBPlDetailsHeader(
    label: 'Odds',
    flex: 2,
    valueGetter: (report) => report.odds.toStringAsFixed(2),
    color: (report) => black,
  ),
  SBPlDetailsHeader(
    label: 'Type',
    flex: 2,
    valueGetter: (report) => report.runnerType,
  ),
  SBPlDetailsHeader(
    label: 'Placed',
    flex: 2,
    valueGetter: (report) => formatDateString(report.createdDate),
  ),
  SBPlDetailsHeader(
    label: 'Profit/Loss',
    flex: 2,
    valueGetter: (report) => formattedAmounts(report.creditAmount - report.debitAmount),
    color: (report) => (report.creditAmount - report.debitAmount) < 0 ? red : black,
  ),
];

class SBPlDetails extends StatelessWidget {
  final SportsBookModel report;
  const SBPlDetails({required this.report, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double leftSpacerWidth = availableWidth * 0.22;
        final double detailsWidth = (availableWidth - leftSpacerWidth - 2).clamp(0.0, double.infinity);
        final double grandTotalPnl = report.creditAmount - report.debitAmount;

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
                const VerticalDivider(
                  color: borderColor,
                  width: 2,
                ),
                SizedBox(
                  width: detailsWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8ED),
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: sbPlDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      header.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: headerTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderColor)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: sbPlDetailsHeaders.map((header) {
                              return Expanded(
                                flex: (header.flex * 10).toInt(),
                                child: Align(
                                  alignment: header.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      header.valueGetter(report),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: header.color != null ? header.color!(report) : black,
                                        decoration: header.label == 'Platform' ? TextDecoration.underline : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Container(
                        color: const Color(0xFFD9E4EC),
                        width: double.infinity,
                        child: Column(
                          children: [
                            _buildTotalsRow('Total Stakes', report.debitAmount),
                            _buildTotalsRow('Back subtotal', report.debitAmount),
                            _buildTotalsRow('Market subtotal', grandTotalPnl, valueColor: grandTotalPnl < 0 ? red : black),
                            const Divider(height: 1, color: borderColor),
                            _buildTotalsRow(
                              'Net Market Total',
                              grandTotalPnl,
                              valueColor: (grandTotalPnl) < 0
                                  ? red
                                  : (grandTotalPnl) > 0
                                      ? black
                                      : black,
                              isBold: true,
                            ),
                          ],
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

  Widget _buildTotalsRow(String label, double value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 8),
          Expanded(
            flex: 2,
            child: HighlightText(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: HighlightText(
                formattedAmounts(value),
                style: TextStyle(
                  color: valueColor ?? black,
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
