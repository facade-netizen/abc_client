import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import 'inplay_filter_popup.dart';

class InplayFilterCard extends StatelessWidget {
  const InplayFilterCard({super.key, required this.sportsList, required this.onFilterSelected});
  final List<String> sportsList;
  final void Function(List<String>) onFilterSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: lightBlueShade,
        border: Border(bottom: BorderSide(color: textColor)),
      ),
      child: Row(
        children: [
          Text(
            'Sport Filters:',
            style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: (sportsList.isNotEmpty)
                ? Row(
                    children: List.generate(sportsList.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${index == 0 ? '' : '• '} ${sportsList[index]}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w400, color: textColor, fontSize: 15),
                        ),
                      );
                    }),
                  )
                : SizedBox(),
          ),
          InplayFilterPopup(
            title: 'sport filter',
            onFilterSelected: onFilterSelected,
          ),
        ],
      ),
    );
  }
}
