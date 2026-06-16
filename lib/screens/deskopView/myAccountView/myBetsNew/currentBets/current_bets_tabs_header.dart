import 'package:flutter/material.dart';

import '../../../../../reusables/colors.dart';
import '../../../../../reusables/download_report.dart';
import '../../../../../reusables/highlighted_text_widget.dart';
import '../../../../../reusables/row_dropdown.dart';
import '../profitAndLoss/profit_and_loss_widgets.dart';

class CurrentBetsTabsHeader extends StatelessWidget {
  const CurrentBetsTabsHeader({
    super.key,
    required this.bettingTabs,
    required this.selectedBettingTabIndex,
    required this.onTabChanged,
    required this.selectedStatus,
    required this.statusList,
    required this.onStatusChanged,
    required this.isSortByBetPlaced,
    required this.onSortBetPlaced,
    required this.onSortMarket,
    required this.downloadHeaderTitles,
    required this.downloadRowData,
  });

  final List<String> bettingTabs;
  final int selectedBettingTabIndex;
  final ValueChanged<int> onTabChanged;

  final String selectedStatus;
  final List<String> statusList;
  final ValueChanged<String> onStatusChanged;

  final bool isSortByBetPlaced;
  final VoidCallback onSortBetPlaced;
  final VoidCallback onSortMarket;
  final List<String> downloadHeaderTitles;
  final List<List<String>> downloadRowData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrolling keeps the betting-type tabs usable on narrower widths.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              bettingTabs.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: CustomTabBtn(
                  bettingTabs[index],
                  isActive: selectedBettingTabIndex == index,
                  onTap: () => onTabChanged(index),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accountStatementHeaderBg,
            border: Border(
              top: BorderSide(color: tileOrFontColor, width: 5),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              // Status filter controls whether both tables render or only one section is shown.
              RowDropdown<String>(
                title: 'Bet Status',
                value: selectedStatus,
                items: statusList,
                width: 160,
                height: 34,
                onChanged: (value) {
                  if (value == null) return;
                  onStatusChanged(value);
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HighlightText('Order By', style: TextStyle(fontSize: 14, color: black)),
                  const SizedBox(width: 8),
                  // These checkboxes behave like a two-option sorter toggle.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSortByBetPlaced,
                        onChanged: (_) => onSortBetPlaced(),
                        side: BorderSide(color: black),
                        checkColor: white,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return primary;
                            }
                            return none;
                          },
                        ),
                      ),
                      const HighlightText('Bet placed', style: TextStyle(fontSize: 14, color: black)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: !isSortByBetPlaced,
                        onChanged: (_) => onSortMarket(),
                        side: BorderSide(color: black),
                        checkColor: white,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return primary;
                            }
                            return none;
                          },
                        ),
                      ),
                      const HighlightText('Market', style: TextStyle(fontSize: 14, color: black)),
                    ],
                  ),

                  /// download reports in excel
                  DownloadReport(
                    height: 30,
                    reportName: 'Current Bets',
                    headerTitles: downloadHeaderTitles,
                    rowData: downloadRowData,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
