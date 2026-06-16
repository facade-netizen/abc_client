import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/signalRBloc/singnalRStreamers/mm_fancy_signalr_data_streamer.dart';
import '../../../../constants/lists/screen_string_list.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/mm_fancy_model.dart';
import '../../../../reusables/sized_box_hw.dart';
import 'mm_fancy_bet_header.dart';
import 'mm_fancy_bet_tile.dart';

class MmFancyBetView extends StatefulWidget {
  const MmFancyBetView({
    super.key,
    required this.fancyMarkets,
    this.favStakeData,
  });
  final FavStakeData? favStakeData;
  final Map<String, MMFancyMarketData> fancyMarkets;

  @override
  State<MmFancyBetView> createState() => _MmFancyBetViewState();
}

class _MmFancyBetViewState extends State<MmFancyBetView> {
  int activeIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MmYesNoTileHeader(),

        /// Market List (Merge → Remove → Filter)
        BlocBuilder<SignalRMMFancyDataBloc, SignalRMMFancyDataState>(
          builder: (context, state) {
            Map<String, MMFancyMarketData> mergedList = Map.from(widget.fancyMarkets);
            final currentEventId = widget.fancyMarkets.values.isNotEmpty ? widget.fancyMarkets.values.first.eventId : null;
            if (state is SignalRMMFancyDataSuccess && currentEventId != null) {
              state.fancy.forEach((key, value) {
                if (value.eventId == currentEventId) {
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
            Map<String, MMFancyMarketData> filteredList = Map.fromEntries(
              mergedList.entries.where((entry) {
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
                final market = filteredList.values.elementAt(index);
                return MmFancyBetTile(
                  favStakeData: widget.favStakeData,
                  fancyBet: market,
                  idx: index,
                  activeIndex: activeIndex,
                  eventId: market.eventId,
                  action: (idx) => setState(() => activeIndex = idx),
                  marketType: market.marketType,
                  marketName: market.marketName,
                  eventName: market.eventName ?? "",
                );
              },
            );
          },
        ),
        hb50,
      ],
    );
  }
}
