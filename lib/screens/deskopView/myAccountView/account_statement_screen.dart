import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../models/user_details_model.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/download_report.dart';
import '../../../reusables/loader.dart';
import '../sportsReusables/table_cell_card.dart';
import 'balance_overrview_screen.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
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
                ? AccountStatementTable(
                    statements:
                        fud.userDetails.history.where((acc) => acc.transType.toLowerCase().contains("deposit") || acc.transType.toLowerCase().contains("withdraw")).toList(),
                    key: Key('acc_statement_table_at_${DateTime.now().toIso8601String()}'),
                  )
                : DataNotFound(message: "Account data not available");
      },
    );
  }
}

class AccountStatementTable extends StatelessWidget {
  const AccountStatementTable({
    super.key,
    required this.statements,
  });
  final List<History> statements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TableHeader(title: "Account statement"),
            const Spacer(),
            DownloadReport(
              reportName: 'Account Statement',
              headerTitles: balanceColumns.map((e) => e.title).toList(),
              rowData: generateBalanceRowData(statements),
            ),
          ],
        ),

        /// Table data
        Expanded(
          child: CustomTable<History>(columns: balanceColumns, data: statements),
        ),
      ],
    );
  }
}
