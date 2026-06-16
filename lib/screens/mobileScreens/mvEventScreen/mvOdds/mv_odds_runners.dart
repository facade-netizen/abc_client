import 'package:flutter/material.dart';

import '../../../../models/fav_stake_model.dart';
import '../../../../models/odd_data_model.dart';
import 'mv_odds_market_card.dart';

class MvOddsRunners extends StatefulWidget {
  const MvOddsRunners({super.key, required this.oddsData, this.favStakeData});
  final ODDSData oddsData;
  final FavStakeData? favStakeData;
  @override
  State<MvOddsRunners> createState() => _MvOddsRunnersState();
}

class _MvOddsRunnersState extends State<MvOddsRunners> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffe0e6e6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Color(0xffe0e6e6)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.oddsData.runners.where((runner) => runner.status.toLowerCase() != 'loser').length,
              itemBuilder: (context, index) {
                final oddsData = widget.oddsData;
                final runner = widget.oddsData.runners.where((runner) => runner.status.toLowerCase() != 'loser').toList()[index];
                return MVOddsRunnerCard(runner: runner, oddsData: oddsData, favStakeData: widget.favStakeData);
              },
            ),
          ),
        ],
      ),
    );
  }
}
