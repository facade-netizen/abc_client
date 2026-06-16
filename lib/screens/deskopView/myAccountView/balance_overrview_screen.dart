import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../models/user_details_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/download_report.dart';
import '../../../reusables/loader.dart';
import '../sportsReusables/table_cell_card.dart';

class BalanceOverviewScreen extends StatefulWidget {
  const BalanceOverviewScreen({super.key});

  @override
  State<BalanceOverviewScreen> createState() => _BalanceOverviewScreenState();
}

class _BalanceOverviewScreenState extends State<BalanceOverviewScreen> {
  @override
  void initState() {
    context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
      builder: (context, fud) {
        return fud is FetchUserAccountDetailsInitial || fud is FetchUserAccountDetailsProgress
            ? LoaderContainerWithMessage()
            : fud is FetchUserAccountDetailsSuccess
                ? BalanceOverviewTable(
                    userDetails: fud.userDetails,
                    key: Key('balance_overview_table_at_${DateTime.now().toIso8601String()}'),
                  )
                : DataNotFound(message: "Balance data not available");
      },
    );
  }
}

class BalanceOverviewTable extends StatelessWidget {
  const BalanceOverviewTable({
    super.key,
    required this.userDetails,
  });
  final UserAccountDetails userDetails;
  @override
  Widget build(BuildContext context) {
    final balanceHistory = userDetails.history.where((pl) => pl.transType == "Deposit" || pl.transType == "Withdraw").toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TableHeader(title: "Summary"),
            const Spacer(),
            DownloadReport(
              reportName: 'Balance Overview',
              headerTitles: balanceColumns.map((e) => e.title).toList(),
              rowData: generateBalanceRowData(balanceHistory),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            color: white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableHeader(title: "Your Balances", fontSize: 18, color: darkGreen, vertical: 8),
                      TableHeader(title: userDetails.balancePoint.toStringAsFixed(2), fontSize: 25, color: blueColor, vertical: 8),
                    ],
                  ),
                ),
                VerticalDivider(color: grey, indent: 10, endIndent: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableHeader(title: "Welcome,", fontSize: 18, color: darkGreen, vertical: 8),
                      TableHeader(
                        fontWeight: FontWeight.normal,
                        title: "View your account details here. You can manage funds, review and change your settings and see the performance of your betting activity.",
                        vertical: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Table data
        Expanded(
          child: CustomTable<History>(
            columns: balanceColumns,
            data: balanceHistory,
            emptyMessage: 'No Balance Data',
          ),
        ),
      ],
    );
  }
}

final List<TableColumn<History>> balanceColumns = [
  TableColumn<History>(
    title: 'Sl No.',
    width: 70,
    cellBuilder: (_, index) => TableCellCard(value: (index + 1).toString()),
  ),
  TableColumn<History>(
    width: 150,
    title: 'Date',
    cellBuilder: (h, _) => TableCellCard(value: h.date),
  ),
  TableColumn<History>(
    width: 150,
    title: 'Transaction Type',
    cellBuilder: (h, _) => TableCellCard(
      value: h.transType,
      color: h.transType.toLowerCase().contains('deposit')
          ? green
          : h.transType.toLowerCase().contains('withdraw')
              ? red
              : black,
    ),
  ),
  TableColumn<History>(
    width: 150,
    title: 'Amount',
    cellBuilder: (h, _) => TableCellCard(value: h.amount.toStringAsFixed(2)),
  ),
  TableColumn<History>(
    title: 'Comment',
    flex: 4,
    cellBuilder: (h, _) => TableCellCard(value: h.comment),
  ),
];
List<List<String>> generateBalanceRowData(List<History> balanceHistory) {
  return balanceHistory.asMap().entries.map((entry) {
    final index = entry.key;
    final h = entry.value;
    return [
      (index + 1).toString(),
      h.date,
      h.transType,
      h.amount.toStringAsFixed(2),
      h.comment,
    ];
  }).toList();
}
