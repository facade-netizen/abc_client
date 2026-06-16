import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_mm_fancy_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_user_mm_fancy_pl_bloc.dart';
import '../../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../models/favourite_model.dart';
import '../../../../models/mm_fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';

class FavBetHeader extends StatelessWidget {
  const FavBetHeader({super.key, required this.eventData, this.removeMarket, this.refreshMarket, this.gotoMarket});
  final FavouriteEventData eventData;
  final void Function()? removeMarket;
  final void Function()? refreshMarket;
  final void Function()? gotoMarket;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      color: darkGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: removeMarket,
            child: Tooltip(
              message: 'Remove from Multi Markets',
              decoration: BoxDecoration(color: black),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  height: 30,
                  width: 30,
                  color: green,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(AppAssetConstants.pin, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 18, width: 18),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: gotoMarket,
              child: Row(
                children: [
                  HighlightText(
                    eventData.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: white),
                  ),
                  if (eventData.favType == FavType.odds)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: HighlightText('Match Odds', style: TextStyle(color: black, fontSize: 10)),
                        ),
                      ),
                    ),
                  if (eventData.favType == FavType.bookmaker) ShowSportsIcon(),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: refreshMarket,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(AppAssetConstants.refersh, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 22, width: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowSportsIcon extends StatelessWidget {
  const ShowSportsIcon({super.key, this.svgIcon});
  final String? svgIcon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: SvgPicture.asset(AppAssetConstants.clockWhite, height: 14),
          ),
          Container(
            decoration: BoxDecoration(
              color: blue,
              borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: SvgPicture.asset(svgIcon ?? AppAssetConstants.b, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 14),
          ),
        ],
      ),
    );
  }
}

class FancyFavBetHeader extends StatelessWidget {
  const FancyFavBetHeader({super.key, required this.eventData, this.gotoMarket});
  final MMFancyMarketData eventData;
  final void Function()? gotoMarket;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      color: darkGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: eventData.eventId, favType: FavType.lines));
            },
            child: Tooltip(
              message: 'Remove from Multi Markets',
              decoration: BoxDecoration(color: black),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  height: 30,
                  width: 30,
                  color: green,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(AppAssetConstants.pin, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 18, width: 18),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: gotoMarket,
              child: Row(
                children: [
                  HighlightText(
                    eventData.eventName ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: white),
                  ),
                  ShowSportsIcon(svgIcon: AppAssetConstants.f),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<FetchMMFancyBloc>().add(FetchMMFancy());
              context.read<FetchUserMMFancyPLBloc>().add(FetchUserMMFancyPL());
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(AppAssetConstants.refersh, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 22, width: 22),
            ),
          ),
        ],
      ),
    );
  }
}
