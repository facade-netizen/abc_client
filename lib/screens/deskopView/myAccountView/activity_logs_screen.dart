import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../../models/activity_log_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/download_report.dart';
import '../../../reusables/loader.dart';
import '../sportsReusables/table_cell_card.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
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
        return als is FetchUserActivityLogsProgress
            ? LoaderContainerWithMessage()
            : als is FetchUserActivityLogsSuccess
                ? ActivityLogsTable(logs: als.activityLogsResponse.data)
                : DataNotFound(message: "Activity logs not available");
      },
    );
  }
}

class ActivityLogsTable extends StatelessWidget {
  const ActivityLogsTable({super.key, required this.logs});
  final List<ActivityLogsData> logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TableHeader(title: "Activity Log"),
            const Spacer(),
            DownloadReport(
              reportName: 'Activity Logs',
              headerTitles: activityLogsColumns.map((e) => e.title).toList(),
              rowData: generateActivityLogsRowData(logs),
            ),
          ],
        ),
        Expanded(
          child: CustomTable<ActivityLogsData>(
            columns: activityLogsColumns,
            data: logs,
            emptyMessage: 'No Activity Logs',
          ),
        ),
      ],
    );
  }
}

final List<TableColumn<ActivityLogsData>> activityLogsColumns = [
  TableColumn<ActivityLogsData>(
    title: 'Sl No.',
    width: 70,
    cellBuilder: (_, index) => TableCellCard(value: (index + 1).toString()),
  ),
  TableColumn<ActivityLogsData>(
    width: 150,
    title: 'Login Date & Time',
    cellBuilder: (l, _) => TableCellCard(value: l.loginTime),
  ),
  TableColumn<ActivityLogsData>(
    width: 120,
    title: 'Login Status',
    cellBuilder: (l, _) => TableCellCard(
      value: l.loginStatus,
      color: l.loginStatus == "Login Success"
          ? green
          : l.loginStatus == "Login Failed"
              ? red
              : black,
    ),
  ),
  TableColumn<ActivityLogsData>(
    title: 'IP Address',
    width: 120,
    cellBuilder: (l, _) => TableCellCard(value: l.ip),
  ),
  TableColumn<ActivityLogsData>(
    title: 'ISP',
    flex: 3,
    cellBuilder: (l, _) => TableCellCard(value: l.isp),
  ),
  TableColumn<ActivityLogsData>(
    title: 'City/State/Country',
    flex: 3,
    cellBuilder: (l, _) => TableCellCard(value: l.address),
  ),
  TableColumn<ActivityLogsData>(
    title: 'User Agent Type',
    width: 150,
    cellBuilder: (l, _) => TableCellCard(value: l.agent),
  ),
];

List<List<String>> generateActivityLogsRowData(List<ActivityLogsData> logs) {
  return logs.asMap().entries.map((entry) {
    final index = entry.key;
    final l = entry.value;
    return [
      (index + 1).toString(),
      l.loginTime,
      l.loginStatus,
      l.ip,
      l.isp,
      l.address,
      l.agent,
    ];
  }).toList();
}
