import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_line_result_bloc.dart';
import '../../../models/result_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/loader.dart';

class ResultLineTile extends StatefulWidget {
  const ResultLineTile({super.key, required this.tab});
  final String tab;

  @override
  State<ResultLineTile> createState() => _ResultLineTileState();
}

class _ResultLineTileState extends State<ResultLineTile> {
  @override
  void initState() {
    super.initState();
    bool isYesterDay = widget.tab == 'Yesterday';
    context.read<FetchLineResultBloc>().add(FetchLineResult(isYesterDay: isYesterDay));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchLineResultBloc, FetchLineResultState>(
      builder: (context, lrs) {
        List<ResultLineData> data = [];
        if (lrs is FetchLineResultSuccess) {
          data = lrs.data;
        }
        return lrs is FetchLineResultProgress
            ? LoaderContainerWithMessage()
            : Container(
                width: double.infinity,
                color: white,
                child: data.isEmpty
                    ? Center(
                        child: Text(
                          "No data",
                          style: TextStyle(color: black),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ResultLineCard(data: data[index]);
                          },
                        ),
                      ),
              );
      },
    );
  }
}

String formatOpenDate(String openDate) {
  try {
    final dateTime = DateTime.parse(openDate);
    final date = '${dateTime.year.toString().padLeft(4, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    return '$date $time';
  } catch (_) {
    return openDate.replaceAll('-', '/').replaceAll('T', ' ');
  }
}

final List<String> filters = ["All", "Three Selections", "Overs", "Batsman", "Single Over", "Ball by Ball", "Khadda", "Lottery", "Odd Event"];

const Map<String, String> marketTypeMap = {
  "Overs": "overs",
  "Batsman": "batsman",
  "Single Over": "single_over",
  "Ball by Ball": "ball_by_ball_session",
  "Three Selections": "three_selections",
  "Khadda": "khadda",
  "Lottery": "lottery",
  "Odd Event": "odd_even",
};

class ResultLineCard extends StatefulWidget {
  const ResultLineCard({super.key, required this.data});
  final ResultLineData data;

  @override
  State<ResultLineCard> createState() => _ResultLineCardState();
}

class _ResultLineCardState extends State<ResultLineCard> {
  Set<String> isExpanded = {};
  String selectedFilter = "Overs";

  List<MarketLineModel> getFilteredMarkets() {
    if (selectedFilter == "All") {
      return widget.data.details;
    }

    final filterType = marketTypeMap[selectedFilter];
    if (filterType == null) {
      return widget.data.details;
    }

    return widget.data.details.where((m) => m.marketType.toLowerCase() == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (isExpanded.contains(widget.data.eventId)) {
              isExpanded.remove(widget.data.eventId);
            } else {
              isExpanded.add(widget.data.eventId);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: darkGreen, border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: HighlightText(
                          formatOpenDate(widget.data.openDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      HighlightText(
                        widget.data.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded.contains(widget.data.eventId) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                  color: white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded.contains(widget.data.eventId))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 35,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = selectedFilter == filter;
                      return InkWell(
                        onTap: () => setState(() => selectedFilter = filter),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: filter == 'All' ? 20 : 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0XFF417393) : const Color(0XFFD0D0D0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: HighlightText(
                              filter,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? white : black,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (getFilteredMarkets().isEmpty) LNData(),
              if (getFilteredMarkets().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0XFFCED5DA),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      RLCell(val: "Market Name", flex: 2, isHeader: true),
                      RLCell(val: "Result (Runs)", isHeader: true),
                      RLCell(val: "Result Source", isHeader: true),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: getFilteredMarkets().length,
                  itemBuilder: (context, index) {
                    final market = getFilteredMarkets()[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          RLCell(val: market.marketName, flex: 2),
                          RLCell(val: market.result),
                          RLCell(val: market.source),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class LNData extends StatelessWidget {
  const LNData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          SizedBox(width: 16),
          HighlightText(
            "No data",
            style: TextStyle(color: black),
          ),
        ],
      ),
    );
  }
}

class RLCell extends StatelessWidget {
  const RLCell({
    super.key,
    required this.val,
    this.flex = 1,
    this.isHeader = false,
  });
  final String val;
  final int flex;
  final bool isHeader;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: HighlightText(
        val,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: flex == 2 ? TextAlign.start : TextAlign.end,
        style: TextStyle(
          color: black,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
