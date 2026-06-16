import 'package:flutter/material.dart';

import '../../../models/event_with_type_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/formatters.dart';
import '../../../reusables/highlighted_text_widget.dart';

String capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

class InplayEventTile extends StatefulWidget {
  const InplayEventTile({super.key, required this.sport, this.isSelected = false, this.action, required this.eve});

  final void Function()? action;
  final Sport sport;
  final Event eve;
  final bool isSelected;

  @override
  State<InplayEventTile> createState() => _InplayEventTileState();
}

class _InplayEventTileState extends State<InplayEventTile> {
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
          height: 40,
          width: size.width,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? whiteOpac1
                : isHovered
                ? highlightTileHover
                : white,
            border: Border(bottom: BorderSide(color: whiteOpac1)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: HighlightText(
                    formatUtcToLocal(widget.eve.openDate, tommorow: true),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                SportsTypeCard(title: capitalize(widget.sport.name)),
                Expanded(
                  child: Text(
                    widget.eve.name,
                    style: TextStyle(fontSize: 14, color: highlightTileText, fontWeight: FontWeight.w600, decoration: isHovered ? TextDecoration.underline : TextDecoration.none),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SportsTypeCard extends StatelessWidget {
  const SportsTypeCard({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: title.isNotEmpty,
      child: Row(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: black, fontWeight: FontWeight.normal, fontSize: 13),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.play_arrow, color: whiteOpac1, size: 16),
          ),
        ],
      ),
    );
  }
}

class InplayTabCard extends StatelessWidget {
  const InplayTabCard({super.key, this.action, required this.title, required this.selectedTab});
  final String title;
  final String selectedTab;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        width: 230,
        height: 35,
        decoration: BoxDecoration(
          color: selectedTab == title ? blueDark : white,
          border: Border.all(color: black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(color: selectedTab == title ? white : black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> inplayTab = ['In-Play', 'Today', 'Tomorrow'];
