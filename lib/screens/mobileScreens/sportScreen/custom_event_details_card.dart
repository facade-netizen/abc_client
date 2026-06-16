import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/app_asset_constants.dart';
import '../../../models/event_with_type_model.dart';
import '../../../models/favourite_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/game_tag.dart';
import '../../../reusables/indicator.dart';
import '../../../reusables/sized_box_hw.dart';

class CustomEventDetailsCard extends StatefulWidget {
  const CustomEventDetailsCard({super.key, required this.event, this.onTap, this.addFavTap, this.pinColor});
  final Event event;
  final Color? pinColor;
  final void Function()? onTap;
  final void Function()? addFavTap;
  @override
  State<CustomEventDetailsCard> createState() => _CustomEventDetailsCardState();
}

class _CustomEventDetailsCardState extends State<CustomEventDetailsCard> {
  bool isLive = false;
  bool fancyMarket = false;
  bool bmMarket = false;
  bool oddsMarket = false;
  bool eSportMarket = false;
  bool premiumMatch = false;

  @override
  void initState() {
    super.initState();
    isLive = widget.event.inPlay;
    fancyMarket = widget.event.fancyMarket;
    bmMarket = widget.event.bookMakerMarket;
    oddsMarket = widget.event.oddsMarket;
    eSportMarket = widget.event.eSportMarket;
    premiumMatch = widget.event.premiumMatch;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          color: white,
          border: Border(bottom: BorderSide(color: grey, width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (isLive) PlayTag(),
                          if (fancyMarket) wb5,
                          if (fancyMarket) FBTag(isFTag: true),
                          if (bmMarket) wb5,
                          if (bmMarket) FBTag(isFTag: false),
                          if (premiumMatch) wb5,
                          if (premiumMatch) PTag(),
                          wb5,
                          if (!isLive) wb5,
                          if (isLive) SessionTag(value: widget.event.openDate, isLive: isLive),
                          if (!isLive) SessionTag(value: widget.event.openDate),
                          wb5,
                          if (eSportMarket) EsportWithTitle(gameTitle: "Soccer"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        LiveIndicator(isLive: isLive),
                        wb10,
                        SizedBox(
                          width: 300,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            widget.event.name,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: blueColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.addFavTap,
                child: SvgPicture.asset(AppAssetConstants.pinblue, width: 28, height: 28, colorFilter: ColorFilter.mode(widget.pinColor ?? grey, BlendMode.srcIn)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomMVMultiMarketEventDetailsCard extends StatefulWidget {
  const CustomMVMultiMarketEventDetailsCard({super.key, required this.event, this.onTap, this.addFavTap, this.pinColor});
  final FavouriteEventData event;
  final Color? pinColor;
  final void Function()? onTap;
  final void Function()? addFavTap;
  @override
  State<CustomMVMultiMarketEventDetailsCard> createState() => _CustomMVMultiMarketEventDetailsCardState();
}

class _CustomMVMultiMarketEventDetailsCardState extends State<CustomMVMultiMarketEventDetailsCard> {
  bool isLive = false;
  bool fancyMarket = false;
  bool bmMarket = false;
  bool oddsMarket = false;
  bool eSportMarket = false;
  bool premiumMatch = false;

  @override
  void initState() {
    super.initState();
    isLive = widget.event.inPlay;
    fancyMarket = widget.event.fancyMarket;
    bmMarket = widget.event.bookMakerMarket;
    oddsMarket = widget.event.oddsMarket;
    eSportMarket = widget.event.eSportMarket;
    premiumMatch = widget.event.premiumMatch;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          color: white,
          border: Border(bottom: BorderSide(color: grey, width: 0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(35, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (isLive) PlayTag(),
                          if (fancyMarket) wb5,
                          if (fancyMarket) FBTag(isFTag: true),
                          if (bmMarket) wb5,
                          if (bmMarket) FBTag(isFTag: false),
                          if (premiumMatch) wb5,
                          if (premiumMatch) PTag(),
                          if (isLive) wb5,
                          SessionTag(value: widget.event.openDate, isLive: isLive),
                          wb5,
                          if (eSportMarket) EsportWithTitle(gameTitle: "Soccer"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        wb10,
                        LiveIndicator(isLive: isLive),
                        wb10,
                        SizedBox(
                          width: 300,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            widget.event.name,
                            style: TextStyle(overflow: TextOverflow.ellipsis, color: blueColor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.addFavTap,
                child: SvgPicture.asset(AppAssetConstants.pinblue, width: 28, height: 28, colorFilter: ColorFilter.mode(widget.pinColor ?? grey, BlendMode.srcIn)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
