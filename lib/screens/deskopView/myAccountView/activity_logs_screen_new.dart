import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../../models/activity_log_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/download_report.dart';
import '../../../reusables/loader.dart';
import '../sportsReusables/table_cell_card.dart';

class ActivityLogsScreenNew extends StatefulWidget {
  const ActivityLogsScreenNew({super.key});

  @override
  State<ActivityLogsScreenNew> createState() => _ActivityLogsScreenNewState();
}

class _ActivityLogsScreenNewState extends State<ActivityLogsScreenNew> {
  int currentPage = 1;
  final int limit = 25;
  int totalPages = 1;
  final Map<int, List<ActivityLogsData>> _pageCache = <int, List<ActivityLogsData>>{};

  @override
  void initState() {
    super.initState();
    fetchPage(currentPage);
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    // If page is already loaded, switch instantly without hitting bloc/API.
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    setState(() => currentPage = safePage);
    context.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogs(page: safePage, limit: limit));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
      builder: (context, als) {
        if (als is FetchUserActivityLogsSuccess) {
          totalPages = als.activityLogsResponse.totalPages;
          _pageCache[als.activityLogsResponse.page] = als.activityLogsResponse.data;
        }

        final List<ActivityLogsData> currentPageLogs = _pageCache[currentPage] ?? const <ActivityLogsData>[];
        return als is FetchUserActivityLogsProgress
            ? LoaderContainerWithMessage()
            : als is FetchUserActivityLogsSuccess
                ? ActivityLogsTable(
                    logs: currentPageLogs,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    pageSize: limit,
                    onPageTap: fetchPage,
                    onPrevious: () {
                      if (currentPage <= 1) return;
                      fetchPage(currentPage - 1);
                    },
                    onNext: () {
                      if (currentPage >= totalPages) return;
                      fetchPage(currentPage + 1);
                    },
                  )
                : DataNotFound(message: "Activity logs not available");
      },
    );
  }
}

class ActivityLogsTable extends StatelessWidget {
  const ActivityLogsTable({
    super.key,
    required this.logs,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
  });
  final List<ActivityLogsData> logs;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final int serialStart = ((currentPage - 1) * pageSize) + 1;
    final List<TableColumn<ActivityLogsData>> columns = buildActivityLogsColumns(serialStart: serialStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TableHeader(title: "Activity Log"),
            const Spacer(),
            DownloadReport(
              reportName: 'Activity Logs',
              headerTitles: columns.map((e) => e.title).toList(),
              rowData: generateActivityLogsRowData(logs, serialStart: serialStart),
            ),
          ],
        ),
        Expanded(
          child: CustomPaginatedTable<ActivityLogsData>(
            columns: columns,
            data: logs,
            currentPage: currentPage,
            totalPages: totalPages,
            onPageTap: onPageTap,
            onPrevious: onPrevious,
            onNext: onNext,
            emptyMessage: 'No Activity Logs',
          ),
        ),
      ],
    );
  }
}

List<TableColumn<ActivityLogsData>> buildActivityLogsColumns({required int serialStart}) {
  return [
  TableColumn<ActivityLogsData>(
    title: 'Sl No.',
    width: 70,
    cellBuilder: (_, index) => TableCellCard(value: (serialStart + index).toString()),
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
}

List<List<String>> generateActivityLogsRowData(List<ActivityLogsData> logs, {int serialStart = 1}) {
  return logs.asMap().entries.map((entry) {
    final index = entry.key;
    final l = entry.value;
    return [
      (serialStart + index).toString(),
      l.loginTime,
      l.loginStatus,
      l.ip,
      l.isp,
      l.address,
      l.agent,
    ];
  }).toList();
}
