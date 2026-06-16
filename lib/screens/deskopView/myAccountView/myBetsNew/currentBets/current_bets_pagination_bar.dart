import 'package:flutter/material.dart';

class CurrentBetsPaginationBar extends StatelessWidget {
  const CurrentBetsPaginationBar({
    super.key,
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
        _PageIndexButton(
          label: '$page',
          isActive: page == currentPage,
          onTap: () => onPageTap(page),
        ),
      );
      buttons.add(const SizedBox(width: 4));
    }

    void addEllipsis() {
      buttons.add(const _PageEllipsis());
      buttons.add(const SizedBox(width: 4));
    }

    // Keep the full list for short result sets and collapse long ranges with ellipses.
    if (totalPages <= 11) {
      for (int page = 1; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    if (currentPage <= 6) {
      for (int page = 1; page <= 10; page++) {
        addPageButton(page);
      }
      addEllipsis();
      addPageButton(totalPages);
      return buttons;
    }

    if (currentPage >= totalPages - 5) {
      addPageButton(1);
      addEllipsis();
      for (int page = totalPages - 9; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    addPageButton(1);
    addEllipsis();
    for (int page = currentPage - 4; page <= currentPage + 4; page++) {
      addPageButton(page);
    }
    addEllipsis();
    addPageButton(totalPages);
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 1;
    final bool canGoNext = currentPage < totalPages;

    // Pagination controls are stateless; parent widgets own the active page.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          label: 'Prev',
          enabled: canGoPrevious,
          onTap: onPrevious,
        ),
        const SizedBox(width: 6),
        ..._buildPageButtons(),
        const SizedBox(width: 6),
        _PageButton(
          label: 'Next',
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PageIndexButton extends StatelessWidget {
  const _PageIndexButton({
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

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        '...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
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
