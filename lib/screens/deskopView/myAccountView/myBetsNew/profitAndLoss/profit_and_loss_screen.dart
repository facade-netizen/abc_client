import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/fetchBlocs/fetch_cg_history_bloc.dart';
import '../../../../../blocs/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../../../../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../../../../../models/casion_history_model.dart';
import '../../../../../models/players_profit_and_loss_model.dart';
import '../../../../../models/user_details_model.dart';
import '../../../../../reusables/buttons.dart';
import '../../../../../reusables/calender.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/download_report.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/highlighted_text_widget.dart';
import '../../../../../reusables/sized_box_hw.dart';
import 'casino_history_table.dart';
import 'exchange_pl_table.dart';
import 'profit_and_loss_widgets.dart';
import 'sb_pl_table.dart';

const List<String> _profitLossDownloadHeaders = <String>[
  'Market',
  'Start Time',
  'Settled Date',
  'Profit/Loss',
];

const List<String> _casinoProfitLossDownloadHeaders = <String>[
  'Bet Type',
  'Profit/Loss',
];

class ProfitAndLossScreen extends StatefulWidget {
  const ProfitAndLossScreen({super.key, this.currentUser});
  final UserAccountDetails? currentUser;

  @override
  State<ProfitAndLossScreen> createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  int selectedTabIndex = 0;
  int casinoPage = 1;
  final int casinoLimit = 15;
  int exchangePage = 1;
  final int exchangeLimit = 10;
  int sportsPage = 1;
  final int sportsLimit = 15;
  String? casinoFromDate;
  String? casinoToDate;

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final ScrollController filterHorizontalController = ScrollController();

  // Map of tabs with their bettingType values
  final Map<String, int?> tabsMap = {
    'Exchange': 0,
    'BookMaker': 2,
    'FancyBet': 1,
    'SportsBook': null,
    'Casino': null,
  };

  // Get tabs list from map keys
  List<String> get tabs => tabsMap.keys.toList();
  bool get isCasinoSelected => selectedTabIndex == 4;
  bool get isSportsSelected => selectedTabIndex == 3;

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    filterHorizontalController.dispose();
    super.dispose();
  }

  /// Returns null for tabs that should not trigger any API call.
  int? get bettingType {
    final selectedTab = tabs[selectedTabIndex];
    return tabsMap[selectedTab];
  }

  void _onTabTap(int index) {
    setState(() => selectedTabIndex = index);
    context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLossInt());
    context.read<FetchCGHistoryBloc>().add(FetchCGHistoryInt());
  }

  /// Common API trigger method
  void _fetchProfitLoss({
    required String from,
    required String to,
    int page = 1,
  }) {
    if (bettingType == null && !isCasinoSelected && !isSportsSelected) return;

    final Map<String, dynamic> data = {
      "userName": widget.currentUser?.userName ?? '',
      "from": from,
      "to": to,
      "bettingType": bettingType,
      "isDone": true,
      "status": 'filled',
      "page": page,
      "limit": exchangeLimit,
    };
    if (isCasinoSelected) {
      final String fromForCG = fromToDateTimeString(fromDateController.text, startOfDay: true);
      final String toForCG = fromToDateTimeString(toDateController.text, startOfDay: false);
      setState(() {
        selectedTabIndex = tabs.indexOf('Casino');
        casinoPage = 1;
        casinoFromDate = fromForCG;
        casinoToDate = toForCG;
      });
      context.read<FetchCGHistoryBloc>().add(FetchCGHistory(fromDate: fromForCG, toDate: toForCG, limit: casinoLimit, page: casinoPage));
    } else if (isSportsSelected) {
      setState(() {
        selectedTabIndex = tabs.indexOf('SportsBook');
        sportsPage = page;
      });
      final String fromForSB = fromToDateTimeString(fromDateController.text, startOfDay: true);
      final String toForSB = fromToDateTimeString(toDateController.text, startOfDay: false);
      context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistory(status: "filled", limit: sportsLimit, page: page, fromDate: fromForSB, toDate: toForSB));
    } else {
      setState(() {
        exchangePage = page;
      });
      context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLoss(getPlayerPl: data));
    }
  }

  void _fetchHistory() {
    final from = stringDateToDateTimeString(
      fromDateController.text,
      startOfDay: true,
    );

    final to = stringDateToDateTimeString(toDateController.text);
    _fetchProfitLoss(from: from, to: to);
  }

  void _fetchPlayerProfitLossPage(int page) {
    final String from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final String to = stringDateToDateTimeString(toDateController.text);
    setState(() => exchangePage = page);
    final Map<String, dynamic> data = {
      "userName": widget.currentUser?.userName ?? '',
      "from": from,
      "to": to,
      "bettingType": bettingType,
      "isDone": true,
      "status": 'filled',
      "page": page,
      "limit": exchangeLimit,
    };
    context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLoss(getPlayerPl: data));
  }

  void _fetchSportsBookHistoryPage(int page) {
    final String from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final String to = stringDateToDateTimeString(toDateController.text);
    setState(() => sportsPage = page);
    context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistory(
          status: "filled",
          limit: sportsLimit,
          page: page,
          fromDate: from,
          toDate: to,
        ));
  }

  void _fetchCasinoHistoryPage(int page) {
    if (casinoFromDate == null || casinoToDate == null) return;
    setState(() => casinoPage = page);
    context.read<FetchCGHistoryBloc>().add(FetchCGHistory(
          fromDate: casinoFromDate!,
          toDate: casinoToDate!,
          limit: casinoLimit,
          page: page,
        ));
  }

  List<List<String>> _downloadRowData(List<PlayerProfitAndLossResponseResult> resultList) {
    return resultList.map((PlayerProfitAndLossResponseResult item) {
      return <String>[
        '${item.eventTypeName.toUpperCase()} > ${item.eventName} > ${item.marketName}',
        item.startTime,
        item.settledDate,
        formattedAmounts(item.pl),
      ];
    }).toList();
  }

  List<CasinoHistoryData> _casinoResultList(BuildContext context) {
    final fetchState = context.watch<FetchCGHistoryBloc>().state;
    return fetchState is FetchCGHistorySuccess ? fetchState.response.data : <CasinoHistoryData>[];
  }

  List<List<String>> _casinoDownloadRowData(List<CasinoHistoryData> casinoList) {
    return casinoList.map((CasinoHistoryData item) {
      return <String>[
        item.betType,
        formattedAmounts(item.pnl),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final List<PlayerProfitAndLossResponseResult> resultList = isCasinoSelected ? <PlayerProfitAndLossResponseResult>[] : _playerResultList(context);
    final List<CasinoHistoryData> casinoResultList = isCasinoSelected ? _casinoResultList(context) : <CasinoHistoryData>[];
    final List<List<String>> downloadRowData = isCasinoSelected ? _casinoDownloadRowData(casinoResultList) : _downloadRowData(resultList);
    final List<String> headerTitles = isCasinoSelected ? _casinoProfitLossDownloadHeaders : _profitLossDownloadHeaders;
    final DateTime now = DateTime.now();
    final String dateTimeLabel = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final fetchState = context.watch<FetchCGHistoryBloc>().state;
    final int casinoTotalPages = fetchState is FetchCGHistorySuccess ? fetchState.response.totalPages : 1;
    final int currentCasinoPage = fetchState is FetchCGHistorySuccess ? fetchState.response.page : casinoPage;
    final fetchStatePl = context.watch<FetchPlayerProfitAndLossBloc>().state;
    final int exchangeCurrentPage = fetchStatePl is FetchPlayerProfitAndLossSuccess ? fetchStatePl.response.page : exchangePage;
    final int exchangeTotalPages = fetchStatePl is FetchPlayerProfitAndLossSuccess ? fetchStatePl.response.totalPages : 1;
    final fetchStateSb = context.watch<FetchSportsBookHistoryBloc>().state;
    final int sportsCurrentPage = fetchStateSb is FetchSportsBookHistorySuccess ? fetchStateSb.page : sportsPage;
    final int sportsTotalPages = fetchStateSb is FetchSportsBookHistorySuccess ? fetchStateSb.totalPages : 1;

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: white,
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HighlightText(
                            'Profit & Loss - ',
                            style: TextStyle(
                              fontSize: 18,
                              color: tileOrFontColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: tileOrFontColor),
                              const SizedBox(width: 4),
                              HighlightText(
                                widget.currentUser?.userName ?? '-',
                                style: const TextStyle(fontSize: 14, color: tileOrFontColor),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HighlightText(
                            'Main wallet',
                            style: TextStyle(
                              fontSize: 18,
                              color: tileOrFontColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled, size: 18, color: tileOrFontColor),
                              const SizedBox(width: 4),
                              HighlightText(
                                dateTimeLabel,
                                style: const TextStyle(fontSize: 14, color: tileOrFontColor),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Tabs
                  SingleChildScrollView(
                    controller: filterHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        tabs.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: CustomTabBtn(
                            tabs[index],
                            isActive: selectedTabIndex == index,
                            onTap: () => _onTabTap(index),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Filter Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: accountStatementHeaderBg,
                      border: Border(
                        top: BorderSide(color: tileOrFontColor, width: 5),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PeriodFilterCard(
                          fromDateController: fromDateController,
                          toDateController: toDateController,
                        ),
                        hb10,
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            CustomOCTAButton(
                              title: 'Just For Today',
                              action: () {
                                final now = DateTime.now();
                                final dateText = now.toIso8601String().split('T').first;
                                fromDateController.text = dateText;
                                final from = stringDateToDateTimeString(now.toIso8601String(), startOfDay: true);
                                final to = stringDateToDateTimeString(now.toIso8601String());
                                _fetchProfitLoss(from: from, to: to);
                              },
                            ),
                            CustomOCTAButton(
                              title: 'From Yesterday',
                              action: () {
                                final yesterday = DateTime.now().subtract(const Duration(days: 1));
                                final dateText = yesterday.toIso8601String().split('T').first;
                                fromDateController.text = dateText;
                                final from = stringDateToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
                                final to = stringDateToDateTimeString(yesterday.toIso8601String());
                                _fetchProfitLoss(from: from, to: to);
                              },
                            ),
                            CustomECTAButton(
                              title: 'Get P & L',
                              action: _fetchHistory,
                            ),
                            DownloadReport(
                              height: 30,
                              reportName: 'Profit & Loss',
                              headerTitles: headerTitles,
                              rowData: downloadRowData,
                            ),
                          ],
                        ),
                        hb10,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isCasinoSelected
                ? CasinoHistoryTable(
                    currentPage: currentCasinoPage,
                    totalPages: casinoTotalPages,
                    onPageChanged: _fetchCasinoHistoryPage,
                  )
                : isSportsSelected
                    ? SBPlHistoryTable(
                        currentPage: sportsCurrentPage,
                        totalPages: sportsTotalPages,
                        onPageChanged: _fetchSportsBookHistoryPage,
                      )
                    : ExchangePlTable(
                        currentPage: exchangeCurrentPage,
                        totalPages: exchangeTotalPages,
                        onPageChanged: _fetchPlayerProfitLossPage,
                      ),
          ],
        ),
      ),
    );
  }

  List<PlayerProfitAndLossResponseResult> _playerResultList(BuildContext context) {
    final fetchState = context.watch<FetchPlayerProfitAndLossBloc>().state;
    return fetchState is FetchPlayerProfitAndLossSuccess ? fetchState.resultList : <PlayerProfitAndLossResponseResult>[];
  }
}
