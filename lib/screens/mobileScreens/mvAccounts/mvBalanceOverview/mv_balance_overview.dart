import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_headers.dart';
import '../../../../reusables/loader.dart';
import '../../../deskopView/myAccountView/balance_overrview_screen.dart';

class MVBalanceOverview extends StatelessWidget {
  const MVBalanceOverview({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
              builder: (context, fud) {
                return AccountMenuHeader(
                  title: title,
                  reportName: 'Balance Overview',
                  headerTitles: balanceColumns.map((e) => e.title).toList(),
                  rowData: generateBalanceRowData(
                    fud is FetchUserAccountDetailsSuccess ? fud.userDetails.history.where((pl) => pl.transType == "Deposit" || pl.transType == "Withdraw").toList() : [],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
                builder: (context, fud) {
                  return fud is FetchUserAccountDetailsProgress
                      ? LoaderContainerWithMessage()
                      : fud is FetchUserAccountDetailsSuccess
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                    child: Card(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Balance",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            fud.userDetails.balancePoint.toStringAsFixed(2),
                                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: account,
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 2, child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 3, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 3, child: Text("Comment", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: fud.userDetails.history.where((pl) => pl.transType == "Deposit" || pl.transType == "Withdraw").length,
                                    itemBuilder: (context, index) {
                                      final balanceHis = fud.userDetails.history.where((pl) => pl.transType == "Deposit" || pl.transType == "Withdraw").toList();
                                      final history = balanceHis[index];
                                      return Container(
                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(history.transType, style: TextStyle(color: history.transType.toLowerCase().contains('deposit') ? green : red))),
                                            Expanded(flex: 3, child: Text(history.amount.toStringAsFixed(2), style: TextStyle(color: black))),
                                            Expanded(flex: 2, child: Text(history.date, style: TextStyle(color: black))),
                                            Expanded(flex: 3, child: Text(history.comment.isEmpty ? '-' : history.comment, style: TextStyle(color: black))),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
