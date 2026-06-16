import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../../../../../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../../../../../models/player_bet_history_model.dart';
import '../../../../../models/user_details_model.dart';
import '../../../../../reusables/buttons.dart';
import '../../../../../reusables/calender.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/download_report.dart';
import '../../../../../reusables/formatters.dart';
import '../../../../../reusables/row_dropdown.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../../reusables/snack_bar.dart';
import '../profitAndLoss/profit_and_loss_widgets.dart';
import 'betting_history_table.dart';
import 'sports_books_history_table.dart';

const List<String> _bettingHistoryDownloadHeaders = <String>[
  'Bet ID',
  'PL ID',
  'Market',
  'Selection',
  'Type',
  'Bet placed',
  'Odds req.',
  'Stake',
  'Avg. odds matched',
  'Profit/Loss',
];

class BettingHistoryScreen extends StatefulWidget {
  const BettingHistoryScreen({super.key, this.currentUser});
  final UserAccountDetails? currentUser;

  @override
  State<BettingHistoryScreen> createState() => _BettingHistoryScreenState();
}

class _BettingHistoryScreenState extends State<BettingHistoryScreen> {
  int selectedTabIndex = 0;

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final ScrollController filterHorizontalController = ScrollController();

  // Map of tabs with their bettingType values
  final Map<String, int?> tabsMap = {'Exchange': 0, 'BookMaker': 2, 'FancyBet': 1, 'SportsBook': null};

  // Get tabs list from map keys
  List<String> get tabs => tabsMap.keys.toList();

  String selectedStatus = 'Settled';
  final List<String> statuses = ['Settled', 'Voided'];

  int sportsBookCurrentPage = 1;
  static const int sportsBookPageSize = 10;

  int playerCurrentPage = 1;
  int playerTotalPages = 1;

  bool get isSportsBookSelected => tabs[selectedTabIndex] == 'SportsBook';

  int? get bettingType {
    final selectedTab = tabs[selectedTabIndex];
    return tabsMap[selectedTab];
  }

  @override
  void initState() {
    super.initState();
    context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    filterHorizontalController.dispose();
    super.dispose();
  }

  /// ---------------- STATUS HELPER ----------------

  Map<String, dynamic> getStatusParams() {
    String? statusParam;
    if (selectedStatus == 'Settled') {
      statusParam = 'filled'; // API expects Filled
    } else if (selectedStatus == 'Voided') {
      statusParam = 'void'; // API expects Voided
    }
    return {"isDone": true, "status": statusParam};
  }

  /// ---------------- COMMON FETCH METHOD ----------------

  void fetchBetHistory({required String from, required String to, int page = 1}) {
    final statusData = getStatusParams();
    final String? userName = nullIfEmpty(widget.currentUser?.userName.trim());
    final Map<String, dynamic> data = {
      "userName": userName,
      "from": from,
      "to": to,
      "bettingType": bettingType,
      "isDone": statusData["isDone"],
      'side': null,
      "status": nullIfEmpty(statusData["status"]?.toString().toLowerCase()),
      'page': page,
      'limit': 10,
    };
    if (isSportsBookSelected) {
      final String fromForSB = fromToDateTimeString(fromDateController.text, startOfDay: true);
      final String toForSB = fromToDateTimeString(toDateController.text, startOfDay: false);
      final String status = statusData["status"];
      sportsBookCurrentPage = page;
      context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistory(status: status, limit: sportsBookPageSize, page: page, fromDate: fromForSB, toDate: toForSB));
      return;
    }
    setState(() => playerCurrentPage = page);
    context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetHistory(getPlayerData: data));
  }

  T? nullIfEmpty<T>(T? value) {
    if (value == null) return null;

    if (value is String && value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  /// ---------------- DATE FILTERS ----------------

  void fetchToday() {
    final now = DateTime.now();
    final dateText = now.toIso8601String().split('T').first;
    fromDateController.text = dateText;
    final from = stringDateToDateTimeString(now.toIso8601String(), startOfDay: true);
    final to = stringDateToDateTimeString(now.toIso8601String());

    fetchBetHistory(from: from, to: to);
  }

  void fetchYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateText = yesterday.toIso8601String().split('T').first;
    fromDateController.text = dateText;
    final from = stringDateToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
    final to = stringDateToDateTimeString(yesterday.toIso8601String());

    fetchBetHistory(from: from, to: to);
  }

  void fetchCustomHistory() {
    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDateController.text);
    setState(() => playerCurrentPage = 1);
    fetchBetHistory(from: from, to: to, page: 1);
  }

  void fetchSportsBookHistoryPage(int page) {
    final statusData = getStatusParams();
    final String fromForSB = fromToDateTimeString(fromDateController.text, startOfDay: true);
    final String toForSB = fromToDateTimeString(toDateController.text, startOfDay: false);
    final String status = statusData["status"];
    setState(() => sportsBookCurrentPage = page);
    context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistory(status: status, limit: sportsBookPageSize, page: page, fromDate: fromForSB, toDate: toForSB));
  }

  void onTabTap(int index) {
    setState(() {
      selectedTabIndex = index;
      sportsBookCurrentPage = 1;
      playerCurrentPage = 1;
    });
    context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
  }

  List<List<String>> _downloadRowData(List<PlayerBetHistory> playerBets) {
    return playerBets.map((PlayerBetHistory bet) {
      final bool isBack = bet.side.toLowerCase().contains('back');

      return <String>[
        bet.orderId.toString(),
        bet.userName,
        '${bet.sportName} > ${bet.eventName} > ${bettingTypeName(bet.bettingType)}',
        bet.bettingType == BettingType.line ? bet.marketName : bet.runnerName,
        bet.bettingType == BettingType.line ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay'),
        formatDateString(bet.timeStamp),
        formattedAmounts(bet.price),
        formattedAmounts(bet.stake),
        formattedAmounts(bet.filledPrice),
        formattedAmounts(bet.mtm),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fetchState = context.watch<FetchPlayerBetHistoryBloc>().state;
    final fetchSportsBookState = context.watch<FetchSportsBookHistoryBloc>().state;
    final int sportsBookTotalPages = fetchSportsBookState is FetchSportsBookHistorySuccess ? fetchSportsBookState.totalPages : 1;
    final int sportsBookPage = fetchSportsBookState is FetchSportsBookHistorySuccess ? fetchSportsBookState.page : sportsBookCurrentPage;
    final int playerPage = fetchState is FetchPlayerBetHistorySuccess ? fetchState.page : playerCurrentPage;
    final int playerTotalPages = fetchState is FetchPlayerBetHistorySuccess ? fetchState.totalPages : this.playerTotalPages;
    final List<PlayerBetHistory> playerBets = isSportsBookSelected || fetchState is! FetchPlayerBetHistorySuccess ? <PlayerBetHistory>[] : fetchState.playerBets;
    final List<List<String>> downloadRowData = _downloadRowData(playerBets);

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Tabs
            SingleChildScrollView(
              controller: filterHorizontalController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: CustomTabBtn(tabs[index], isActive: selectedTabIndex == index, onTap: () => onTabTap(index)),
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
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      RowDropdown<String>(
                        title: 'Bet Status',
                        value: selectedStatus,
                        items: statuses,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatus = value);
                          }
                        },
                      ),
                      PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
                    ],
                  ),
                  hb10,

                  /// Action Buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      CustomOCTAButton(title: 'Just For Today', action: fetchToday),
                      CustomOCTAButton(title: 'Yesterday', action: fetchYesterday),
                      CustomECTAButton(title: 'Get History', action: fetchCustomHistory),

                      /// Download button uses the same filters to generate the report data, so no separate method is needed. Just pass the current filter values as props.
                      DownloadReport(height: 30, reportName: 'Betting History', headerTitles: _bettingHistoryDownloadHeaders, rowData: downloadRowData),
                    ],
                  ),
                ],
              ),
            ),

            if (isSportsBookSelected)
              SBHistoryTable(
                currentPage: sportsBookPage,
                totalPages: sportsBookTotalPages,
                onPageChange: fetchSportsBookHistoryPage,
              )
            else
              BlocListener<FetchPlayerBetHistoryBloc, FetchPlayerBetHistoryState>(
                listener: (context, state) {
                  if (state is FetchPlayerBetHistoryFailure) {
                    showSnackBar(context, state.error.toString(), error: true);
                  }
                },
                child: BettingHistoryTable(
                  currentPage: playerPage,
                  totalPages: playerTotalPages,
                  onPageChange: (page) {
                    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
                    final to = stringDateToDateTimeString(toDateController.text);
                    fetchBetHistory(from: from, to: to, page: page);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
