import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/highlighted_text_widget.dart';

class TableCellCard extends StatelessWidget {
  const TableCellCard({
    super.key,
    this.isHeader = false,
    required this.value,
    this.color,
    this.child,
  });
  final Color? color;
  final String value;
  final bool isHeader;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return HighlightText.rich(
      value,
      textSpan: TextSpan(
        style: TextStyle(
          color: color ?? (isHeader ? darkGreen : black),
          fontSize: isHeader ? 14 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        children: [
          if (child != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: SizedBox(child: child),
              ),
            ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
    required this.title,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.vertical = 8,
  });
  final double? fontSize;
  final Color? color;
  final String title;
  final double vertical;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: HighlightText(
        title,
        style: TextStyle(color: color ?? black, fontSize: fontSize ?? 15, fontWeight: fontWeight ?? FontWeight.bold),
      ),
    );
  }
}

class TableColumn<T> {
  final String title;
  final int flex;
  final double? width;
  final Widget Function(T row, int index) cellBuilder;

  const TableColumn({
    required this.title,
    required this.cellBuilder,
    this.flex = 2,
    this.width,
  });
}

Widget tableCell({
  required TableColumn column,
  required Widget child,
}) {
  return column.width != null ? SizedBox(width: column.width, child: child) : Expanded(flex: column.flex, child: child);
}

class CustomTable<T> extends StatelessWidget {
  const CustomTable({
    super.key,
    required this.columns,
    required this.data,
    this.emptyMessage = 'No Data',
  });

  final List<TableColumn<T>> columns;
  final List<T> data;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: white,
            border: Border(
              top: BorderSide(color: darkGreen, width: 1),
              bottom: BorderSide(color: darkGreen, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: columns.map((c) {
                return tableCell(
                  column: c,
                  child: TableCellCard(value: c.title, isHeader: true),
                );
              }).toList(),
            ),
          ),
        ),

        /// Rows
        Expanded(
          child: data.isEmpty
              ? DataNotFound(message: emptyMessage)
              : ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(grey),
                    trackColor: WidgetStateProperty.all(Colors.grey.shade100),
                    thumbVisibility: WidgetStateProperty.all(true),
                    trackVisibility: WidgetStateProperty.all(true),
                    thickness: WidgetStateProperty.all(10),
                    radius: const Radius.circular(10),
                    minThumbLength: 50,
                    crossAxisMargin: 2,
                    mainAxisMargin: 2,
                    interactive: true,
                  ),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final row = data[index];
                      return Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border(
                            bottom: BorderSide(color: grey, width: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            children: columns.map((c) {
                              return tableCell(
                                column: c,
                                child: c.cellBuilder(row, index),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class CustomPaginatedTable<T> extends StatelessWidget {
  const CustomPaginatedTable({
    super.key,
    required this.columns,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
    this.emptyMessage = 'No Data',
  });

  final List<TableColumn<T>> columns;
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final int safeTotalPages = totalPages < 1 ? 1 : totalPages;
    final int safeCurrentPage = currentPage.clamp(1, safeTotalPages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: white,
            border: Border(
              top: BorderSide(color: darkGreen, width: 1),
              bottom: BorderSide(color: darkGreen, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: columns.map((c) {
                return tableCell(
                  column: c,
                  child: TableCellCard(value: c.title, isHeader: true),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: data.isEmpty
              ? DataNotFound(message: emptyMessage)
              : ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(grey),
                    trackColor: WidgetStateProperty.all(Colors.grey.shade100),
                    thumbVisibility: WidgetStateProperty.all(true),
                    trackVisibility: WidgetStateProperty.all(true),
                    thickness: WidgetStateProperty.all(10),
                    radius: const Radius.circular(10),
                    minThumbLength: 50,
                    crossAxisMargin: 2,
                    mainAxisMargin: 2,
                    interactive: true,
                  ),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final row = data[index];
                      return Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border(
                            bottom: BorderSide(color: grey, width: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            children: columns.map((c) {
                              return tableCell(
                                column: c,
                                child: c.cellBuilder(row, index),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 10),
        _TablePaginationBar(
          currentPage: safeCurrentPage,
          totalPages: safeTotalPages,
          onPageTap: onPageTap,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ],
    );
  }
}

class _TablePaginationBar extends StatelessWidget {
  const _TablePaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    void addPageButton(int page) {
      buttons.add(
        _TablePageIndexButton(
          label: '$page',
          isActive: page == currentPage,
          onTap: () => onPageTap(page),
        ),
      );
      buttons.add(const SizedBox(width: 4));
    }

    if (totalPages <= 7) {
      for (int page = 1; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    addPageButton(1);
    final int start = (currentPage - 1).clamp(2, totalPages - 2);
    final int end = (start + 2).clamp(2, totalPages - 1);
    for (int page = start; page <= end; page++) {
      addPageButton(page);
    }
    addPageButton(totalPages);
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 1;
    final bool canGoNext = currentPage < totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TablePageButton(
          label: 'Prev',
          enabled: canGoPrevious,
          onTap: onPrevious,
        ),
        const SizedBox(width: 6),
        ..._buildPageButtons(),
        const SizedBox(width: 6),
        _TablePageButton(
          label: 'Next',
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _TablePageIndexButton extends StatelessWidget {
  const _TablePageIndexButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minWidth: 26),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black.withValues(alpha: 0.75) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? Colors.black.withValues(alpha: 0.3) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? const Color(0xFFE5B84D) : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TablePageButton extends StatelessWidget {
  const _TablePageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey.shade400;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
