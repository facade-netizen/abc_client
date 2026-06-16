import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/signalRBloc/singnalRStreamers/mm_fancy_signalr_data_streamer.dart';
import '../../../../constants/lists/screen_string_list.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/mm_fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import 'mm_mv_fancy_market_card.dart';
import 'mm_mv_three_selection_fancy_market_card.dart';

class MMMvFancyMarkets extends StatefulWidget {
  const MMMvFancyMarkets({super.key, required this.eventId, this.favStakeData, required this.fancyMarkets, required this.sid});
  final String eventId;
  final String sid;
  final FavStakeData? favStakeData;
  final Map<String, MMFancyMarketData> fancyMarkets;

  @override
  State<MMMvFancyMarkets> createState() => _MMMvFancyMarketsState();
}

class _MMMvFancyMarketsState extends State<MMMvFancyMarkets> {
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        BlocBuilder<SignalRMMFancyDataBloc, SignalRMMFancyDataState>(
          builder: (context, frd) {
            Map<String, MMFancyMarketData> mergedList = Map.from(widget.fancyMarkets);
            if (frd is SignalRMMFancyDataSuccess) {
              frd.fancy.forEach((key, value) {
                if (value.eventId == widget.eventId) {
                  final cleanKey = value.marketId.trim();
                  mergedList[cleanKey] = value;
                }
              });
            }
            const blockedStatuses = {
              'closed',
              'removed',
              'removed_vacant',
              'inactive',
              'settled',
              'void',
              'voided',
              'offline',
              'settle_processing',
              'void_processing',
            };
            final selectedMarketType = marketTypes[selectedTabIndex];
            Map<String, MMFancyMarketData> filteredList = Map.fromEntries(
              (selectedMarketType == "All"
                      ? mergedList.entries
                      : mergedList.entries.where(
                          (entry) => entry.value.marketType == selectedMarketType,
                        ))
                  .where((entry) {
                final status = entry.value.status.toLowerCase();
                return !blockedStatuses.contains(status);
              }).toList()
                ..sort((a, b) {
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
                    ? MMMvThreeSelectionFancyMarketCard(
                        fancyMarketData: fancyMarketData,
                        favStakeData: widget.favStakeData,
                      )
                    : MMMvFancyMarketCard(
                        fancyMarketData: fancyMarketData,
                        favStakeData: widget.favStakeData,
                      );
              },
            );
          },
        )
      ],
    );
  }
}
