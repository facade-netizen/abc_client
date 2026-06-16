import 'package:flutter/material.dart';

import '../../../../models/user_details_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_headers.dart';
import 'change_password_dialog.dart';

class MvProfileScreen extends StatelessWidget {
  const MvProfileScreen({super.key, required this.title, this.currentUser});
  final String title;
  final UserAccountDetails? currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          children: [
            AccountMenuHeader(title: title),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 25,
                    width: 500,
                    decoration: const BoxDecoration(color: account),
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text('About You', style: TextStyle(fontSize: 17, color: white)),
                  ),
                  SizedBox(
                    width: 500,
                    child: Table(
                      border: TableBorder(bottom: BorderSide(color: black, width: 0.5)),
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
                      children: [
                        buildTableRow('Account Id', currentUser!.userName),
                        buildTableRow('First Name', currentUser!.firstName),
                        buildTableRow('Last Name', currentUser!.lastName),
                        buildTableRow('Birthday', ''),
                        buildTableRow(
                          'Password',
                          '***************************',
                          onTap: () {
                            showPasswordChangeDialog(context);
                          },
                        ),
                        buildTableRow('Time Zone', 'IST'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(String label, String value, {Function()? onTap}) {
    return TableRow(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: const TextStyle(fontSize: 12, color: black)),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          padding: const EdgeInsets.all(8.0),
          child: label == 'Password'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 12, color: black)),
                    InkWell(
                      onTap: onTap,
                      child: Row(
                        children: [
                          Text("Edit", style: TextStyle(color: blue, fontSize: 12)),
                          const Icon(Icons.edit, size: 16, color: Colors.blue),
                        ],
                      ),
                    ),
                  ],
                )
              : Text(value, style: const TextStyle(fontSize: 12, color: black)),
        ),
      ],
    );
  }
}
