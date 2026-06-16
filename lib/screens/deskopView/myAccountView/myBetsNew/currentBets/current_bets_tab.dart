import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/fetchBlocs/fetch_current_bets_bloc.dart';
import '../../../../../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../../../../../models/open_order_model.dart';
import '../../../../../models/player_bet_history_model.dart';
import '../../../../../models/sportsbook_model.dart';
import '../../../../../models/user_details_model.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/loader.dart';
import 'current_bets_pagination_bar.dart';
import 'current_bets_table_section.dart';
import 'current_bets_tabs_header.dart';
import 'current_sportsbook_table_section.dart';

const List<String> _currentBetsDownloadHeaders = <String>[
  'Market',
  'Selection',
  'Type',
  'Bet ID',
  'Bet placed',
  'Odds req.',
  'Matched',
  'Avg. odds matched / Unmatched',
  'Date matched',
];

class CurrentBetsTab extends StatefulWidget {
  const CurrentBetsTab({super.key, this.currentUser});
  final UserAccountDetails? currentUser;

  @override
  State<CurrentBetsTab> createState() => _CurrentBetsTabState();
}

enum CurrentBetsSortBy { betPlaced, market }

class _CurrentBetsTabState extends State<CurrentBetsTab> {
  // These values drive the top-level filter, grouping, and pagination state.
  int selectedBettingTabIndex = 0;
  String selectedStatus = 'All';
  CurrentBetsSortBy sortBy = CurrentBetsSortBy.betPlaced;
  int currentPage = 1;
  static const int pageSize = 10;
  List<List<String>> downloadRowData = [];
  final List<String> bettingTabs = ['Exchange', 'FancyBet', 'SportsBook', 'BookMaker'];

  List<String> get statusList {
    if (selectedBettingTabIndex == 1 || selectedBettingTabIndex == 3) {
      return const ['All', 'Matched'];
    }
    return const ['All', 'Matched', 'Unmatched'];
  }

  int? _getBetTypeFromTabIndex(int tabIndex) {
    switch (tabIndex) {
      case 0: // Exchange - Odds betting type
        return 0; // or whatever value represents BettingType.odds
      case 1: // FancyBet - Line betting type
        return 1; // or whatever value represents BettingType.line
      case 3: // BookMaker
        return 2; // or whatever value represents BettingType.bookmaker
      default:
        return null;
    }
  }

  void _loadCurrentBets() {
    if (selectedBettingTabIndex == 2) {
      context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistory(status: "open", limit: 50, page: 1));
      return;
    }
    final betType = _getBetTypeFromTabIndex(selectedBettingTabIndex);
    context.read<FetchCurrentBetsBloc>().add(FetchCurrentBets(betType: betType));
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentBets();
  }

  List<OpenOrder> _sortedOrders(List<OpenOrder> orders) {
    final list = [...orders];
    list.sort((a, b) {
      if (sortBy == CurrentBetsSortBy.market) {
        // Market sort keeps related rows together and falls back to newest first.
        int result = a.eventName.compareTo(b.eventName);
        if (result == 0) {
          final DateTime aTime = DateTime.tryParse(a.timeStamp?.toString() ?? '') ?? DateTime(1970);
          final DateTime bTime = DateTime.tryParse(b.timeStamp?.toString() ?? '') ?? DateTime(1970);
          result = bTime.compareTo(aTime);
        }
        return result;
      }

      final DateTime aTime = DateTime.tryParse(a.timeStamp?.toString() ?? '') ?? DateTime(1970);
      final DateTime bTime = DateTime.tryParse(b.timeStamp?.toString() ?? '') ?? DateTime(1970);
      // Default ordering shows the most recently placed bets first.
      return bTime.compareTo(aTime);
    });
    return list;
  }

  int _totalPages(int itemCount) {
    if (itemCount <= 0) return 1;
    return (itemCount / pageSize).ceil();
  }

  List<OpenOrder> _pagedOrders(List<OpenOrder> orders, {required int page}) {
    if (orders.isEmpty) return [];
    final int start = (page - 1) * pageSize;
    final int end = (start + pageSize).clamp(0, orders.length);
    if (start >= orders.length) return [];
    return orders.sublist(start, end);
  }

  List<SportsBookModel> _sortedSportsBookOrders(List<SportsBookModel> orders) {
    final list = [...orders];
    list.sort((a, b) {
      if (sortBy == CurrentBetsSortBy.market) {
        int result = a.eventName.compareTo(b.eventName);
        if (result == 0) {
          final DateTime aTime = DateTime.tryParse(a.createdDate) ?? DateTime(1970);
          final DateTime bTime = DateTime.tryParse(b.createdDate) ?? DateTime(1970);
          result = bTime.compareTo(aTime);
        }
        return result;
      }

      final DateTime aTime = DateTime.tryParse(a.createdDate) ?? DateTime(1970);
      final DateTime bTime = DateTime.tryParse(b.createdDate) ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  List<SportsBookModel> _pagedSportsBookOrders(List<SportsBookModel> orders, {required int page}) {
    if (orders.isEmpty) return [];
    final int start = (page - 1) * pageSize;
    final int end = (start + pageSize).clamp(0, orders.length);
    if (start >= orders.length) return [];
    return orders.sublist(start, end);
  }

  List<List<String>> _downloadRowData({required List<OpenOrder> visibleMatched}) {
    return visibleMatched.map((order) {
      final bool isBack = order.side.toLowerCase().contains('back');
      final bool isMatched = order.isDone || order.filledPrice > 0;
      final String placed = formatDateString(order.timeStamp);
      final String unmatchedAmount = formattedAmounts((order.stake - (order.filledPrice > 0 ? order.stake : 0)).clamp(0, order.stake));

      return <String>[
        '${order.sportName} > ${order.eventName} > ${bettingTypeName(order.bettingType)}',
        order.bettingType == BettingType.line ? order.marketName : order.runnerName,
        order.bettingType == BettingType.line ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay'),
        order.orderId.toString(),
        placed,
        formattedAmounts(order.price),
        formattedAmounts(order.stake),
        isMatched ? formattedAmounts(order.filledPrice) : unmatchedAmount,
        placed,
      ];
    }).toList();
  }

  List<List<String>> _downloadSportsBookRowData({required List<SportsBookModel> visibleMatched}) {
    return visibleMatched.map((order) {
      final bool isBack = order.runnerType.toLowerCase().contains('back');
      final String placed = formatDateString(order.createdDate);

      return <String>[
        '${order.eventName} > ${order.marketName}',
        order.marketName,
        isBack ? 'Back' : 'Lay',
        order.id.toString(),
        placed,
        order.odds.toStringAsFixed(2),
        order.debitAmount.toStringAsFixed(2),
        order.odds.toStringAsFixed(2),
        placed,
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentBetsTabsHeader(
            bettingTabs: bettingTabs,
            selectedBettingTabIndex: selectedBettingTabIndex,
            onTabChanged: (index) => setState(() {
              selectedBettingTabIndex = index;
              currentPage = 1;
              selectedStatus = 'All';
              _loadCurrentBets();
            }),
            selectedStatus: selectedStatus,
            statusList: statusList,
            onStatusChanged: (value) => setState(() {
              selectedStatus = value;
              currentPage = 1;
            }),
            isSortByBetPlaced: sortBy == CurrentBetsSortBy.betPlaced,
            onSortBetPlaced: () => setState(() {
              sortBy = CurrentBetsSortBy.betPlaced;
              currentPage = 1;
            }),
            onSortMarket: () => setState(() {
              sortBy = CurrentBetsSortBy.market;
              currentPage = 1;
            }),
            downloadHeaderTitles: _currentBetsDownloadHeaders,
            downloadRowData: downloadRowData,
          ),
          selectedBettingTabIndex == 2
              ? BlocBuilder<FetchSportsBookHistoryBloc, FetchSportsBookHistoryState>(
                  builder: (context, state) {
                    if (state is FetchSportsBookHistoryInitial || state is FetchSportsBookHistoryProgress) {
                      return const LoaderContainerWithMessage();
                    }
                    final List<SportsBookModel> sportsBookData = state is FetchSportsBookHistorySuccess ? state.sportsBookData : [];
                    final List<SportsBookModel> sortedOrders = _sortedSportsBookOrders(sportsBookData);
                    final List<SportsBookModel> paginationSource = selectedStatus == 'Unmatched' ? [] : sortedOrders;
                    final int totalPages = _totalPages(paginationSource.length);
                    final int safeCurrentPage = currentPage.clamp(1, totalPages);
                    final List<SportsBookModel> pagedSource = _pagedSportsBookOrders(paginationSource, page: safeCurrentPage);
                    final List<SportsBookModel> pagedMatched = _sortedSportsBookOrders(pagedSource);

                    final List<SportsBookModel> visibleMatched = selectedStatus == 'Unmatched' ? [] : pagedMatched;
                    final List<SportsBookModel> visibleUnmatched = [];
                    const bool supportsUnmatched = true;
                    final bool showUnmatchedSection = supportsUnmatched && selectedStatus != 'Matched';
                    final bool showMatchedSection = selectedStatus != 'Unmatched';
                    downloadRowData = _downloadSportsBookRowData(visibleMatched: visibleMatched);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        if (showUnmatchedSection) ...[
                          CurrentSBBetsTableSection(title: 'Unmatched', sportsBookOrders: visibleUnmatched, matchedTable: false),
                          const SizedBox(height: 18),
                        ],
                        if (showMatchedSection) ...[CurrentSBBetsTableSection(title: 'Matched', sportsBookOrders: visibleMatched, matchedTable: false)],
                        if (paginationSource.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          CurrentBetsPaginationBar(
                            currentPage: safeCurrentPage,
                            totalPages: totalPages,
                            onPageTap: (page) {
                              if (page == currentPage) return;
                              setState(() => currentPage = page);
                            },
                            onPrevious: () {
                              if (currentPage <= 1) return;
                              setState(() => currentPage -= 1);
                            },
                            onNext: () {
                              if (currentPage >= totalPages) return;
                              setState(() => currentPage += 1);
                            },
                          ),
                        ],
                      ],
                    );
                  },
                )
              : BlocBuilder<FetchCurrentBetsBloc, FetchCurrentBetsState>(
                  builder: (context, state) {
                    if (state is FetchCurrentBetsInitial || state is FetchCurrentBetsProgress) {
                      return const LoaderContainerWithMessage();
                    }

                    // The screen paginates matched rows only; unmatched is rendered as an empty UI section.
                    final List<OpenOrder> allOrders = state is FetchCurrentBetsSuccess ? state.openOrder : <OpenOrder>[];
                    final List<OpenOrder> matchedOrders = _sortedOrders(allOrders);
                    final bool supportsUnmatched = selectedBettingTabIndex != 1 && selectedBettingTabIndex != 3;

                    final List<OpenOrder> paginationSource = selectedStatus == 'Unmatched' ? [] : matchedOrders;
                    final int totalPages = _totalPages(paginationSource.length);
                    final int safeCurrentPage = currentPage.clamp(1, totalPages);
                    final List<OpenOrder> pagedSource = _pagedOrders(paginationSource, page: safeCurrentPage);
                    final List<OpenOrder> pagedMatched = _sortedOrders((pagedSource));

                    // "All" shows a matched table plus an empty unmatched UI section when supported.
                    final List<OpenOrder> visibleMatched = selectedStatus == 'Unmatched' ? [] : pagedMatched;
                    final List<OpenOrder> visibleUnmatched = [];
                    final bool showUnmatchedSection = supportsUnmatched && selectedStatus != 'Matched';
                    final bool showMatchedSection = selectedStatus != 'Unmatched';
                    downloadRowData = _downloadRowData(visibleMatched: visibleMatched);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        if (showUnmatchedSection) ...[CurrentBetsTableSection(title: 'Unmatched', orders: visibleUnmatched, matchedTable: false), const SizedBox(height: 18)],
                        if (showMatchedSection) ...[CurrentBetsTableSection(title: 'Matched', orders: visibleMatched, matchedTable: true)],
                        if (paginationSource.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          CurrentBetsPaginationBar(
                            currentPage: safeCurrentPage,
                            totalPages: totalPages,
                            onPageTap: (page) {
                              if (page == currentPage) return;
                              setState(() => currentPage = page);
                            },
                            onPrevious: () {
                              if (currentPage <= 1) return;
                              setState(() => currentPage -= 1);
                            },
                            onNext: () {
                              if (currentPage >= totalPages) return;
                              setState(() => currentPage += 1);
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
