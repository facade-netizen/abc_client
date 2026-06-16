import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';

class MvMMHeaderOdds extends StatelessWidget {
  const MvMMHeaderOdds({
    super.key,
    required this.eventName,
    this.removeMarket,
    this.gotoMarket,
    this.refreshMarket,
  });
  final String eventName;
  final void Function()? removeMarket;
  final void Function()? gotoMarket;
  final void Function()? refreshMarket;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: darkGreen,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(onTap: removeMarket, child: SvgPicture.asset(AppAssetConstants.removemarket)),
              wb5,
              Expanded(
                child: Text(
                  eventName,
                  style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3b5160),
                  border: Border.all(color: Color(0xFF3b5160)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(onTap: gotoMarket, child: SvgPicture.asset(AppAssetConstants.arrowleft)),
              ),
              wb5,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF3b5160)),
                ),
                child: InkWell(
                  onTap: refreshMarket,
                  child: SvgPicture.asset(AppAssetConstants.refersh),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  SvgPicture.asset(AppAssetConstants.circleBar),
                  wb5,
                  Text(
                    "Match Odds",
                    style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Back",
                      style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Lay",
                      style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
