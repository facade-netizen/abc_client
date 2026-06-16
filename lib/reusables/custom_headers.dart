import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../services/get_excel_file_from_passed_data_service.dart';
import '../services/navigators.dart';
import 'colors.dart';
import 'sized_box_hw.dart';
import 'snack_bar.dart';
import 'text_style.dart';

class CustomHeadersWithSvgAndTitle extends StatelessWidget {
  const CustomHeadersWithSvgAndTitle({super.key, required this.svgIcon, required this.headerTitle, this.onTap});
  final String svgIcon;
  final String headerTitle;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(gradient: bottomBarGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(svgIcon, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 22, width: 22),
                wb10,
                SizedBox(
                  child: Text(headerTitle, style: customAppBarTitleStyle(), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: appYellow, width: 0.5)),
              ),
              child: Center(child: Icon(Icons.close, color: appYellow)),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomHeadersBlueGredWithTitle extends StatelessWidget {
  const CustomHeadersBlueGredWithTitle({super.key, required this.headerTitle});
  final String headerTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(gradient: mvEventHeader),
      child: Text(
        headerTitle,
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AccountMenuHeader extends StatelessWidget {
  const AccountMenuHeader({
    super.key,
    required this.title,
    this.reportName,
    this.numericColumns,
    this.headerTitles,
    this.rowData,
  });
  final String title;
  final String? reportName;
  final List<int>? numericColumns;
  final List<String>? headerTitles;
  final List<List<String>>? rowData;
  @override
  Widget build(BuildContext context) {
    final bool hasData = rowData != null && rowData!.isNotEmpty;

    return Container(
      height: 40,
      decoration: const BoxDecoration(gradient: bottomBarGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                wb10,
                SizedBox(
                  child: Text(
                    title,
                    style: customAppBarTitleStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (reportName != null)
                InkWell(
                  onTap: hasData
                      ? () async {
                          try {
                            await generateAndDownloadReportInExcel(
                              headerTitles!,
                              rowData!,
                              reportName!,
                            ).then((value) {
                              if (context.mounted) {
                                showSnackBar(context, 'Excel downloaded successfully.');
                              }
                            });
                          } catch (e) {
                            if (context.mounted) {
                              showSnackBar(context, 'Failed: $e', error: true);
                            }
                          }
                        }
                      : null,
                  child: Tooltip(
                    message: "Download Excel Report",
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: appYellow, width: 0.5)),
                      ),
                      child: Center(child: Icon(Icons.download, color: appYellow)),
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  removeScreen(context);
                },
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: appYellow, width: 0.5)),
                  ),
                  child: Center(child: Icon(Icons.close, color: appYellow)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
