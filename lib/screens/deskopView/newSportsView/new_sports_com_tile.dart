import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/indicator.dart';

class NewSportsComTile extends StatefulWidget {
  const NewSportsComTile({
    super.key,
    required this.menu,
    required this.selectedMenu,
    this.action,
  });

  final void Function()? action;
  final String menu, selectedMenu;
  @override
  State<NewSportsComTile> createState() => _NewSportsComTileState();
}

class _NewSportsComTileState extends State<NewSportsComTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.action,
        child: Container(
          height: 30,
          width: size.width,
          decoration: BoxDecoration(
            color: widget.selectedMenu == widget.menu
                ? black
                : isHovered
                    ? highlightHeader.withValues(alpha: 0.1)
                    : white,
            border: Border(
              bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.menu,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.selectedMenu == widget.menu ? white : black,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewSportsComTileDate extends StatelessWidget {
  const NewSportsComTileDate({
    super.key,
    required this.date,
  });
  final String date;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      decoration: BoxDecoration(
        color: Color(0xFFDDDCD6),
        border: Border(
          bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: HighlightText(
        _formatDate(date),
        style: TextStyle(
          color: black,
          fontWeight: FontWeight.normal,
          fontSize: 13,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';

  try {
    // Parse the ISO date string
    final date = DateTime.parse(dateStr);
    final Map<int, String> months = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'};
    return '${months[date.month]} ${date.day}';
  } catch (e) {
    return '';
  }
}

class NewSportsMatchOddsCTA extends StatefulWidget {
  const NewSportsMatchOddsCTA({
    super.key,
    this.action,
    this.inPlay,
    this.isSelected = false,
    required this.title,
  });

  final void Function()? action;
  final bool? inPlay;
  final String title;
  final bool isSelected;
  @override
  State<NewSportsMatchOddsCTA> createState() => _NewSportsMatchOddsCTAState();
}

class _NewSportsMatchOddsCTAState extends State<NewSportsMatchOddsCTA> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.action,
        child: Container(
          height: 30,
          width: size.width,
          decoration: BoxDecoration(
            color: widget.isSelected == true
                ? grey
                : isHovered
                    ? highlightHeader.withValues(alpha: 0.1)
                    : white,
            border: Border(
              bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: LiveIndicatorForDesktop(
                    isLive: widget.inPlay ?? false,
                  ),
                ),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isSelected == true ? white : black,
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomScrollable extends StatelessWidget {
  const CustomScrollable({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(grey),
        trackColor: WidgetStateProperty.all(white),
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(10),
        minThumbLength: 50,
        crossAxisMargin: 2,
        mainAxisMargin: 2,
        interactive: true,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: children,
      ),
    );
  }
}


class NewSportsMoreTileDate extends StatelessWidget {
  const NewSportsMoreTileDate({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      decoration: BoxDecoration(
        color: Color(0xFFDDDCD6),
        border: Border(
          bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        'More',
        style: TextStyle(
          color: black,
          fontWeight: FontWeight.normal,
          fontSize: 13,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}