import 'package:flutter/material.dart';

import '../../../../models/fav_stake_model.dart';
import '../../../../models/favourite_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import 'mv_mm_bm_market_card.dart';

class MvMMBMRunners extends StatefulWidget {
  const MvMMBMRunners({super.key, required this.bmData, this.favStakeData, this.matchOddsRunners});
  final FavouriteEventData bmData;
  final FavStakeData? favStakeData;
  final List<FavRunner>? matchOddsRunners;
  @override
  State<MvMMBMRunners> createState() => _MvMMBMRunnersState();
}

class _MvMMBMRunnersState extends State<MvMMBMRunners> {
  String _normalizeRunnerName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  bool _runnerNamesMatch(String a, String b) {
    final normalizedA = _normalizeRunnerName(a);
    final normalizedB = _normalizeRunnerName(b);

    if (normalizedA == normalizedB) {
      return true;
    }

    const minSimilarityRatio = 0.75;
    if (normalizedA.contains(normalizedB) && normalizedB.length >= normalizedA.length * minSimilarityRatio) {
      return true;
    }
    if (normalizedB.contains(normalizedA) && normalizedA.length >= normalizedB.length * minSimilarityRatio) {
      return true;
    }

    return false;
  }

  List<FavRunner> _getDisplayRunners() {
    final source = widget.bmData.runners;
    final odds = widget.matchOddsRunners;

    if (odds == null || odds.isEmpty) {
      return source.reversed.toList();
    }

    final remaining = List<FavRunner>.from(source);
    final ordered = <FavRunner>[];

    for (final oddRunner in odds) {
      final bmIndex = remaining.indexWhere((bmRunner) => _runnerNamesMatch(bmRunner.name, oddRunner.name));
      if (bmIndex >= 0) {
        ordered.add(remaining.removeAt(bmIndex));
      }
    }

    return ordered.isNotEmpty ? ordered : source.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayRunners = _getDisplayRunners();

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 36,
          decoration: const BoxDecoration(color: Color(0xffe4f1f9)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bookmaker',
                  style: const TextStyle(color: secondaryTextClr, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: Color.fromARGB(188, 250, 247, 200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Back",
                      style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    wb80,
                    Text(
                      "Lay",
                      style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    wb20,
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: displayRunners.length,
                itemBuilder: (context, index) {
                  final runner = displayRunners[index];
                  return MvMMBMRunnerCard(bmRunner: runner, bmData: widget.bmData, favStakeData: widget.favStakeData);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
