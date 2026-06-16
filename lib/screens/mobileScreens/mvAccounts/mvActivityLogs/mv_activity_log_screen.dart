import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_headers.dart';
import '../../../../reusables/loader.dart';
import '../../../deskopView/myAccountView/activity_logs_screen.dart';

class MVActivityLogScreen extends StatefulWidget {
  const MVActivityLogScreen({super.key, required this.title});
  final String title;
  @override
  State<MVActivityLogScreen> createState() => _MVActivityLogScreenState();
}

class _MVActivityLogScreenState extends State<MVActivityLogScreen> {
  int currentPage = 1;
  int maxLoadedPage = 1;
  int limit = 25;

  @override
  void initState() {
    super.initState();
    fetchPage(currentPage);
  }

  void fetchPage(int page) {
    context.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogs(page: page, limit: limit));
    if (page > maxLoadedPage) {
      setState(() {
        maxLoadedPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
      builder: (context, als) {
        return Scaffold(
          backgroundColor: white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountMenuHeader(
                  title: widget.title,
                  reportName: "Activity Logs",
                  headerTitles: activityLogsColumns.map((e) => e.title).toList(),
                  rowData: generateActivityLogsRowData(als is FetchUserActivityLogsSuccess ? als.activityLogsResponse.data : []),
                ),
                Expanded(
                  child: BlocBuilder<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
                    builder: (context, als) {
                      return als is FetchUserActivityLogsProgress
                          ? LoaderContainerWithMessage()
                          : als is FetchUserActivityLogsSuccess
                              ? Column(
                                  children: [
                                    Container(
                                      color: account,
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      child: Row(
                                        children: const [
                                          Expanded(flex: 2, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                          Expanded(flex: 3, child: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                          Expanded(flex: 2, child: Text("IP", style: TextStyle(fontWeight: FontWeight.bold))),
                                          Expanded(flex: 3, child: Text("ISP", style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: als.activityLogsResponse.data.length,
                                        itemBuilder: (context, index) {
                                          final log = als.activityLogsResponse.data[index];
                                          return Container(
                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(color: Colors.grey.shade300),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(flex: 2, child: Text(log.loginStatus, style: TextStyle(color: green))),
                                                Expanded(flex: 3, child: Text(log.loginTime, style: TextStyle(color: black))),
                                                Expanded(flex: 2, child: Text(log.ip, style: TextStyle(color: black))),
                                                Expanded(flex: 3, child: Text(log.isp, style: TextStyle(color: black))),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
