import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_line_result_bloc.dart';
import '../../../../models/result_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/loader.dart';
import '../../../deskopView/resultsView/result_line_tile.dart';
import '../../../deskopView/resultsView/result_sport_dropdown.dart';

class MobileLineResultView extends StatefulWidget {
  const MobileLineResultView({super.key, required this.tab});
  final String tab;

  @override
  State<MobileLineResultView> createState() => MobileLineResultViewState();
}

class MobileLineResultViewState extends State<MobileLineResultView> {
  @override
  void initState() {
    super.initState();
    bool isYesterDay = widget.tab == 'Yesterday';
    context.read<FetchLineResultBloc>().add(FetchLineResult(isYesterDay: isYesterDay));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchLineResultBloc, FetchLineResultState>(
      builder: (context, state) {
        if (state is FetchLineResultProgress) {
          return LoaderContainerWithMessage(message: 'Loading results...');
        }
        if (state is FetchLineResultSuccess) {
          final data = state.data;
          if (data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data', style: TextStyle(color: black)),
              ),
            );
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => MobileFancyCard(data: data[index]),
          );
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No data available.', style: TextStyle(color: black)),
          ),
        );
      },
    );
  }
}

class MobileFancyCard extends StatefulWidget {
  const MobileFancyCard({super.key, required this.data});
  final ResultLineData data;

  @override
  State<MobileFancyCard> createState() => MobileFancyCardState();
}

class MobileFancyCardState extends State<MobileFancyCard> {
  Set<String> isExpanded = {};
  String selectedFilter = 'Overs';

  List<MarketLineModel> get _filteredMarkets {
    if (selectedFilter == 'All') return widget.data.details;
    final filterType = marketTypeMap[selectedFilter];
    if (filterType == null) return widget.data.details;
    return widget.data.details.where((m) => m.marketType.toLowerCase() == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final filtered = _filteredMarkets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match header row
        InkWell(
          onTap: () => setState(() {
            if (isExpanded.contains(widget.data.eventId)) {
              isExpanded.remove(widget.data.eventId);
            } else {
              isExpanded.add(widget.data.eventId);
            }
          }),
          child: Container(
            color: white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatOpenDate(widget.data.openDate),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.eventName,
                        style: const TextStyle(fontSize: 13, color: black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded.contains(widget.data.eventId) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                  color: darkGreen,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Color(0xFFE7EFF3)),

        // Expanded content
        if (isExpanded.contains(widget.data.eventId)) ...[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EFF3),
              border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ResultSportDropdown(
                height: 40,
                width: size.width,
                selectedSport: selectedFilter,
                sports: filters,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFilter = value;
                    });
                  }
                },
              ),
            ),
          ),

          // Data rows
          if (filtered.isEmpty)
            Container(
              color: const Color(0xFFE7EFF3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text('No data', style: TextStyle(color: Colors.grey)),
            )
          else
            ...filtered.map((market) => MobileFancyMarketRow(market: market)),
        ],
      ],
    );
  }
}

class MobileFancyMarketRow extends StatelessWidget {
  const MobileFancyMarketRow({super.key, required this.market});
  final MarketLineModel market;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFF3),
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightText(market.source, style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    HighlightText(
                      market.marketName,
                      style: const TextStyle(fontSize: 13, color: black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: darkGreen, width: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HighlightText('Runs', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    HighlightText(
                      market.result,
                      style: const TextStyle(fontSize: 13, color: black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
