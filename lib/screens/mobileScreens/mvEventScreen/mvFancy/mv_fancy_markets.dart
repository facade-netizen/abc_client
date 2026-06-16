import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../constants/lists/screen_string_list.dart';
import '../../../../models/fancy_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import 'mv_fancy_market_card.dart';
import 'three_selection_fancy_market_card.dart';

class MvFancyMarkets extends StatefulWidget {
  const MvFancyMarkets({super.key, required this.eventId, this.favStakeData, required this.fancyMarkets, required this.sid});
  final String eventId;
  final String sid;
  final FavStakeData? favStakeData;
  final Map<String, FancyMarketData> fancyMarkets;

  @override
  State<MvFancyMarkets> createState() => _MvFancyMarketsState();
}

class _MvFancyMarketsState extends State<MvFancyMarkets> {
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.sid == "4")
          Container(
            color: Colors.teal.shade600,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(marketTypes.length, (index) {
                  final m = marketTypes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                        final marketIds = widget.fancyMarkets.values
                            .where((m) => m.marketType == marketTypes[selectedTabIndex] || marketTypes[selectedTabIndex] == "All")
                            .map((e) => e.marketId)
                            .join(',');
                        context.read<FetchFancyRunnerPLBloc>().add(FetchFancyRunnerPL(eventId: widget.eventId.toString(), marketId: marketIds));
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(color: selectedTabIndex == index ? white : Colors.transparent, borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                m.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(color: selectedTabIndex == index ? black : white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "No",
                style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              wb80,
              Text(
                "Yes",
                style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              wb20,
            ],
          ),
        ),
        BlocBuilder<SignalRFancyDataBloc, SignalRFancyDataState>(
          builder: (context, frd) {
            Map<String, FancyMarketData> mergedList = Map.from(widget.fancyMarkets);
            if (frd is SignalRFancyDataSuccess) {
              frd.fancy.forEach((key, value) {
                final cleanKey = value.marketId.trim();
                mergedList[cleanKey] = value;
              });
            }
            const blockedStatuses = {'closed', 'removed', 'removed_vacant', 'inactive', 'settled', 'void', 'voided', 'offline', 'settle_processing', 'void_processing'};
            final selectedMarketType = marketTypes[selectedTabIndex];
            Map<String, FancyMarketData> filteredList = Map.fromEntries(
              (selectedMarketType == "All" ? mergedList.entries : mergedList.entries.where((entry) => entry.value.marketType == selectedMarketType)).where((entry) {
                final status = entry.value.status.toLowerCase();
                return !blockedStatuses.contains(status);
              }).toList()..sort((a, b) {
                // Primary: sort by marketType order defined in marketTypes list
                final aTypeIdx = marketTypes.indexOf(a.value.marketType);
                final bTypeIdx = marketTypes.indexOf(b.value.marketType);
                final aTypeOrder = aTypeIdx == -1 ? marketTypes.length : aTypeIdx;
                final bTypeOrder = bTypeIdx == -1 ? marketTypes.length : bTypeIdx;
                if (aTypeOrder != bTypeOrder) return aTypeOrder.compareTo(bTypeOrder);

                // Secondary: existing sorting field logic
                final aSort = int.tryParse(a.value.sorting?.toString() ?? '0') ?? 0;
                final bSort = int.tryParse(b.value.sorting?.toString() ?? '0') ?? 0;
                final aIsWholePositive = aSort > 0;
                final bIsWholePositive = bSort > 0;
                if (aIsWholePositive && !bIsWholePositive) return -1;
                if (!aIsWholePositive && bIsWholePositive) return 1;
                if (aIsWholePositive && bIsWholePositive) {
                  return aSort.compareTo(bSort);
                }
                final aHasUnderscore = a.value.marketId.contains('_');
                final bHasUnderscore = b.value.marketId.contains('_');
                if (aHasUnderscore == bHasUnderscore) return 0;
                return aHasUnderscore ? -1 : 1;
              }),
            );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final fancyMarketData = filteredList.values.elementAt(index);
                return fancyMarketData.marketType.startsWith("THREE_SELECTIONS")
                    ? ThreeSelectionFancyMarketCard(fancyMarketData: fancyMarketData, favStakeData: widget.favStakeData)
                    : FancyMarketCard(fancyMarketData: fancyMarketData, favStakeData: widget.favStakeData);
              },
            );
          },
        ),
      ],
    );
  }
}
