import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../../../../../models/sportsbook_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/loader.dart';
import '../../../../../reusables/snack_bar.dart';
import '../profitAndLoss/profit_and_loss_widgets.dart';
import 'sports_books_details.dart';

const int _betIdFlex = 14;
const int _marketFlex = 32;
const int _sectionFlex = 16;
const int _typeFlex = 8;
const int _betPlacedFlex = 14;
const int _oddsReqFlex = 12;
const int _stakeFlex = 10;
const int _avgOddsFlex = 20;
const int _profitLossFlex = 14;

class SBHistoryTable extends StatefulWidget {
  const SBHistoryTable({super.key, required this.currentPage, required this.totalPages, required this.onPageChange});

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  @override
  State<SBHistoryTable> createState() => _SBHistoryTableState();
}

class _SBHistoryTableState extends State<SBHistoryTable> {
  final Set<int> expandedOrderIds = <int>{};
  List<SportsBookModel> sportsBookData = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchSportsBookHistoryBloc, FetchSportsBookHistoryState>(
      builder: (context, state) {
        if (state is FetchSportsBookHistorySuccess) {
          sportsBookData = state.sportsBookData;
        } else if (state is FetchSportsBookHistoryFailure) {
          sportsBookData = [];
          showSnackBar(context, state.error.toString(), error: true);
        } else if (state is FetchSportsBookHistoryProgress || state is FetchSportsBookHistoryInitial) {
          sportsBookData = [];
        }

        if (state is FetchSportsBookHistoryProgress) {
          return LoaderContainerWithMessage();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: sportsBookData.isEmpty
              ? Column(
                  children: const [
                    Heading('Betting History enables you to review the bets you have placed.'),
                    Heading('Specify the time period during which your bets were placed, the type of markets on which the bets were placed, and the sport.'),
                    SizedBox(height: 4),
                    Heading('Betting History is available online for the past 62 days.'),
                    SizedBox(height: 4),
                    Heading(
                      'User can search up to 14 days records per query only. However, when querying Fancy bet with the bet status set to voided, the maximum query period is limited to 2 days.',
                    ),
                  ],
                )
              : Column(
                  children: [
                    const BettingHistoryHeader(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      itemCount: sportsBookData.length,
                      itemBuilder: (context, index) {
                        final sb = sportsBookData[index];
                        final isExpanded = expandedOrderIds.contains(sb.id);
                        return RepaintBoundary(
                          child: SBHistoryTableRow(
                            key: ValueKey<int>(sb.id),
                            sb: sb,
                            isExpanded: isExpanded,
                            onToggleExpand: () {
                              setState(() {
                                if (isExpanded) {
                                  expandedOrderIds.remove(sb.id);
                                } else {
                                  expandedOrderIds.add(sb.id);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _PaginationBar(
                      currentPage: widget.currentPage.clamp(1, widget.totalPages),
                      totalPages: widget.totalPages,
                      onPageTap: (page) {
                        if (page == widget.currentPage) return;
                        widget.onPageChange(page);
                      },
                      onPrevious: () {
                        if (widget.currentPage <= 1) return;
                        widget.onPageChange(widget.currentPage - 1);
                      },
                      onNext: () {
                        if (widget.currentPage >= widget.totalPages) return;
                        widget.onPageChange(widget.currentPage + 1);
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageTap, required this.onPrevious, required this.onNext});

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    void addPageButton(int page) {
      buttons.add(_PageIndexButton(label: '$page', isActive: page == currentPage, onTap: () => onPageTap(page)));
      buttons.add(const SizedBox(width: 4));
    }

    void addEllipsis() {
      buttons.add(const _PageEllipsis());
      buttons.add(const SizedBox(width: 4));
    }

    if (totalPages <= 11) {
      for (int page = 1; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    if (currentPage <= 6) {
      for (int page = 1; page <= 10; page++) {
        addPageButton(page);
      }
      addEllipsis();
      addPageButton(totalPages);
      return buttons;
    }

    if (currentPage >= totalPages - 5) {
      addPageButton(1);
      addEllipsis();
      for (int page = totalPages - 9; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    addPageButton(1);
    addEllipsis();
    for (int page = currentPage - 4; page <= currentPage + 4; page++) {
      addPageButton(page);
    }
    addEllipsis();
    addPageButton(totalPages);
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 1;
    final bool canGoNext = currentPage < totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(label: 'Prev', enabled: canGoPrevious, onTap: onPrevious),
        const SizedBox(width: 6),
        ..._buildPageButtons(),
        const SizedBox(width: 6),
        _PageButton(label: 'Next', enabled: canGoNext, onTap: onNext),
      ],
    );
  }
}

class _PageIndexButton extends StatelessWidget {
  const _PageIndexButton({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minWidth: 26),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black.withValues(alpha: 0.75) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.black.withValues(alpha: 0.3) : Colors.grey.shade400),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: isActive ? const Color(0xFFE5B84D) : Colors.grey.shade700, fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        '...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.label, required this.enabled, required this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey.shade400;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Text(label, style: TextStyle(color: enabled ? Colors.grey.shade700 : Colors.grey.shade500, fontSize: 12)),
      ),
    );
  }
}

class SBHistoryTableRow extends StatelessWidget {
  const SBHistoryTableRow({super.key, required this.sb, required this.isExpanded, required this.onToggleExpand});

  final SportsBookModel sb;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final bool isBack = sb.runnerType.toLowerCase().contains('back');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                /// BET ID
                Expanded(
                  flex: _betIdFlex,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: onToggleExpand,
                          child: Icon(isExpanded ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined, size: 18, color: grey),
                        ),
                        const SizedBox(width: 4),
                        SelectableText(sb.id.toString(), style: const TextStyle(fontSize: 13, color: primary)),
                      ],
                    ),
                  ),
                ),

                /// MARKET (flex 4) — NO CHANGE
                Expanded(
                  flex: _marketFlex,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SelectableText.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        children: [
                          TextSpan(text: "S/R"),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                          ),
                          TextSpan(
                            text: sb.eventName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                          ),
                          TextSpan(text: sb.marketName),
                        ],
                      ),
                    ),
                  ),
                ),

                /// SECTION (flex 2) — NO CHANGE
                Expanded(
                  flex: _sectionFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: sb.marketName),
                ),

                /// TYPE
                Expanded(
                  flex: _typeFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: (isBack ? 'Back' : 'Lay'), color: isBack ? backType : layType),
                ),

                /// DATE
                Expanded(
                  flex: _betPlacedFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: formatDateString(sb.createdDate)),
                ),

                /// ODDS
                Expanded(
                  flex: _oddsReqFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: formattedAmounts(sb.odds)),
                ),

                /// STAKE
                Expanded(
                  flex: _stakeFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: formattedAmounts(sb.debitAmount)),
                ),

                /// AVG ODDS
                Expanded(
                  flex: _avgOddsFlex,
                  child: BettingHistoryRowCell(alignRight: true, title: formattedAmounts(sb.odds)),
                ),

                /// P/L
                Expanded(
                  flex: _profitLossFlex,
                  child: BettingHistoryRowCell(
                    alignRight: true,
                    title: sb.requestType.toLowerCase().contains('voided') ? "Voided" : formattedAmounts(sb.debitAmount - sb.creditAmount),
                    color: sb.requestType.toLowerCase().contains('voided')
                        ? black
                        : sb.debitAmount - sb.creditAmount > 0
                        ? black
                        : sb.debitAmount - sb.creditAmount == 0
                        ? black
                        : red,
                  ),
                ),
              ],
            ),
          ),

          /// EXPANDED
          if (isExpanded) SportsBookDetails(bet: sb),
        ],
      ),
    );
  }
}

class BettingHistoryHeader extends StatelessWidget {
  const BettingHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: headerRowColor,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: _betIdFlex,
            child: BettingHistoryCell(title: 'Bet ID'),
          ),
          Expanded(
            flex: _marketFlex,
            child: BettingHistoryCell(title: 'Market'),
          ),
          Expanded(
            flex: _sectionFlex,
            child: BettingHistoryCell(title: 'Selection', alignRight: true),
          ),
          Expanded(
            flex: _typeFlex,
            child: BettingHistoryCell(title: 'Type', alignRight: true),
          ),
          Expanded(
            flex: _betPlacedFlex,
            child: BettingHistoryCell(title: 'Bet placed', alignRight: true),
          ),
          Expanded(
            flex: _oddsReqFlex,
            child: BettingHistoryCell(title: 'Odds req.', alignRight: true),
          ),
          Expanded(
            flex: _stakeFlex,
            child: BettingHistoryCell(title: 'Stake', alignRight: true),
          ),
          Expanded(
            flex: _avgOddsFlex,
            child: BettingHistoryCell(title: 'Avg. odds matched', alignRight: true),
          ),
          Expanded(
            flex: _profitLossFlex,
            child: BettingHistoryCell(title: 'Profit/Loss', alignRight: true),
          ),
        ],
      ),
    );
  }
}

class BettingHistoryCell extends StatelessWidget {
  const BettingHistoryCell({super.key, required this.title, this.alignRight = false});

  final String title;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SelectableText(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: headerTextColor),
      ),
    );
  }
}

class BettingHistoryRowCell extends StatelessWidget {
  const BettingHistoryRowCell({super.key, required this.title, this.alignRight = false, this.color});

  final String title;
  final bool alignRight;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SelectableText(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 13, color: color ?? black),
      ),
    );
  }
}
