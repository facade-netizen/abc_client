import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../../../../models/players_profit_and_loss_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/highlighted_text_widget.dart';
import '../../../../../reusables/loader.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../../reusables/snack_bar.dart';
import 'exchange_pl_details.dart';
import 'profit_and_loss_widgets.dart';

class ExchangePlTable extends StatefulWidget {
  const ExchangePlTable({super.key, required this.currentPage, required this.totalPages, required this.onPageChanged});

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  State<ExchangePlTable> createState() => _ExchangePlTableState();
}

class _ExchangePlTableState extends State<ExchangePlTable> {
  final Set<int> _expandedIndexes = {};
  String selectedSport = 'ALL';
  List<PlayerProfitAndLossResponseResult> filteredList = [];
  List<String> dropdownItems = [];
  double totalPL = 0.0;
  final ValueNotifier<String?> _sportNotifier = ValueNotifier<String?>('ALL');

  @override
  void dispose() {
    _sportNotifier.dispose();
    super.dispose();
  }

  void _clearCachedData() {
    _expandedIndexes.clear();
    selectedSport = 'ALL';
    filteredList = [];
    dropdownItems = [];
    totalPL = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPlayerProfitAndLossBloc, FetchPlayerProfitAndLossState>(
      builder: (context, state) {
        if (state is FetchPlayerProfitAndLossProgress) {
          _clearCachedData();
          return const LoaderContainerWithMessage();
        }
        if (state is FetchPlayerProfitAndLossFailure) {
          _clearCachedData();
          showSnackBar(context, state.error.toString(), error: true);
        }

        if (state is FetchPlayerProfitAndLossSuccess) {
          final resultList = state.resultList;

          /// Generate unique sport list dynamically
          final sports = resultList.where((e) => e.eventTypeName.isNotEmpty).map((e) => e.eventTypeName).toSet().toList()..sort();
          dropdownItems = ['ALL', ...sports];

          /// Apply filtering
          filteredList = selectedSport == 'ALL' ? resultList : resultList.where((e) => e.eventTypeName == selectedSport).toList();
          // Get sportBets safely
          totalPL = state.response.totalPnl;
        } else {
          _clearCachedData();
        }

        return filteredList.isEmpty
            ? Column(
                children: [
                  hb12,
                  const Heading(
                    'Betting Profit & Loss enables you to review the bets you have placed.\n'
                    'Specify the time period during which your bets were placed, '
                    'the type of markets on which the bets were placed, and the sport.',
                  ),
                  const Heading('Betting Profit & Loss is available online for the past 62 days.'),
                  const Heading('User can search up to 14 days records per query only.'),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hb10,

                  /// Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            HighlightText(
                              'Total P/L:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: black),
                            ),
                            const SizedBox(width: 5),
                            HighlightText(
                              formattedAmounts(totalPL),
                              style: TextStyle(overflow: TextOverflow.ellipsis, color: totalPL < 0 ? red : black, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const Spacer(),

                        /// Dropdown
                        if (dropdownItems.isNotEmpty)
                          SizedBox(
                            height: 32,
                            width: 160,
                            child: DropdownButtonFormField2<String>(
                              iconStyleData: IconStyleData(icon: const Icon(Icons.arrow_drop_down, color: black)),
                              valueListenable: _sportNotifier,
                              isExpanded: true,
                              menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 10)),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: white,
                                contentPadding: const EdgeInsets.only(left: 10, right: 4),
                                hintStyle: TextStyle(color: grey, fontSize: 14),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blue, width: 2)),
                                border: OutlineInputBorder(borderSide: BorderSide(color: grey)),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: grey)),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                elevation: 0,
                                maxHeight: ((dropdownItems.isNotEmpty ? dropdownItems.length : 1) * 30) + 20,
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(color: black),
                                ),
                              ),
                              items: dropdownItems
                                  .map(
                                    (sport) => DropdownItem<String>(
                                      value: sport,
                                      height: 30,
                                      child: Text(sport, style: const TextStyle(fontSize: 14, color: black)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _sportNotifier.value = value;
                                  _expandedIndexes.clear();
                                }
                              },
                            ),
                          ),

                        const SizedBox(width: 5),

                        HighlightText(
                          formattedAmounts(totalPL),
                          style: TextStyle(overflow: TextOverflow.ellipsis, color: totalPL < 0 ? red : black, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  const TableHeader(),

                  /// Event List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final event = filteredList[index];
                      final int globalIndex = index;
                      final isExpanded = _expandedIndexes.contains(globalIndex);

                      return Column(
                        children: [
                          /// Main Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: white,
                              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: SelectableText.rich(
                                      TextSpan(
                                        style: const TextStyle(fontSize: 13, color: Colors.black),
                                        children: [
                                          /// SPORT + ARROW
                                          TextSpan(text: (event.eventTypeName.toUpperCase())),
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                                          ),

                                          /// EVENT (MAIN LINE)
                                          TextSpan(
                                            text: event.eventName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),

                                          /// MARKET NAME + ARROW
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                                          ),
                                          TextSpan(
                                            text: event.marketName.toLowerCase().contains('line') && event.details != null
                                                ? event.details?.orders.first.runnerName
                                                : event.marketName,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: SelectableText(
                                      formattedDate(event.startTime),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText(
                                      formattedDate(event.settledDate),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 13, color: Colors.black),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedIndexes.remove(globalIndex);
                                        } else {
                                          _expandedIndexes.add(globalIndex);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          HighlightText(
                                            formattedAmounts(event.totalPL),
                                            style: TextStyle(overflow: TextOverflow.ellipsis, color: (event.totalPL) < 0 ? red : black),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(isExpanded ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined, size: 18, color: grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Expanded Section
                          SizedBox(child: isExpanded && event.details != null ? ExpandedPlDetails(details: event.details!) : const SizedBox.shrink()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _PaginationBar(
                    currentPage: widget.currentPage,
                    totalPages: widget.totalPages,
                    onPageTap: (page) {
                      if (page == widget.currentPage) return;
                      widget.onPageChanged(page);
                    },
                    onPrevious: () {
                      if (widget.currentPage <= 1) return;
                      widget.onPageChanged(widget.currentPage - 1);
                    },
                    onNext: () {
                      if (widget.currentPage >= widget.totalPages) return;
                      widget.onPageChanged(widget.currentPage + 1);
                    },
                  ),
                  hb30,
                ],
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
