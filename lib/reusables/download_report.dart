import 'package:flutter/material.dart';

import '../../services/get_excel_file_from_passed_data_service.dart';
import 'colors.dart';
import 'snack_bar.dart';

class DownloadReport extends StatelessWidget {
  const DownloadReport({
    super.key,
    this.rowData,
    this.reportName,
    this.headerTitles,
    this.numericColumns,
    this.height,
  });

  final double? height;
  final String? reportName;
  final List<int>? numericColumns;
  final List<String>? headerTitles;
  final List<List<String>>? rowData;

  @override
  Widget build(BuildContext context) {
    final bool hasData = rowData != null && rowData!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Tooltip(
        message: 'Download Excel Report',
        child: DownloadReportButton(
          height: height,
          title: 'Excel',
          icon: Icons.border_all,
          action: hasData
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
        ),
      ),
    );
  }
}

class DownloadReportButton extends StatelessWidget {
  const DownloadReportButton({
    super.key,
    required this.title,
    this.action,
    this.icon,
    this.height,
  });

  final double? height;
  final String title;
  final void Function()? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = action == null;

    return SizedBox(
      height: height ?? 25,
      width: 120,
      child: ElevatedButton.icon(
        icon: Icon(icon ?? Icons.download, size: 16),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isDisabled ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A),
          ),
          foregroundColor: WidgetStateProperty.all(white),
          side: WidgetStateProperty.all(
            BorderSide(
              color: isDisabled ? const Color(0xFF9CA3AF) : const Color(0xFF16A34A),
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          overlayColor: WidgetStateProperty.all(white.withValues(alpha: 0.08)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8),
          ),
          elevation: WidgetStateProperty.all(1),
        ),
        onPressed: action,
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
