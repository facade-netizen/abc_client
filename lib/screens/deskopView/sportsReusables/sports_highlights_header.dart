import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../models/event_with_type_model.dart';
import '../../../models/favourite_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/style.dart';
import '../authView/desktop_login_view.dart';
import '../newSportsView/new_sports_view_screen.dart';

class EventStatus extends StatelessWidget {
  const EventStatus({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      width: (size.width * 0.04) * 2,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
      child: Center(
        child: Text(status, style: b13ts(color: white)),
      ),
    );
  }
}

class AddFevEvent extends StatelessWidget {
  const AddFevEvent({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context) {
    return BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
      listener: (context, afe) {
        if (afe is AddFavouriteEventsSuccess && afe.eventId == eventId) {
          context.read<FetchFavouriteBloc>().add(FetchFavourite());
        }
      },
      child: BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
        listener: (context, rfe) {
          if (rfe is RemoveFavouriteEventsSuccess && rfe.eventId == eventId) {
            context.read<FetchFavouriteBloc>().add(FetchFavourite());
          }
        },
        child: BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
          builder: (context, ucs) {
            SaveLoginTokenModel? userLogedinSaveData;
            if (ucs is UserAuthChangesSuccess) {
              userLogedinSaveData = ucs.savedUserAuth;
            }

            return BlocBuilder<FetchFavouriteBloc, FetchFavouriteState>(
              builder: (context, fes) {
                List<FavouriteEventData> favEvents = [];
                if (fes is FetchFavouriteSuccess) {
                  favEvents = fes.favEvents;
                }
                final isFav = favEvents.any((fav) => fav.id == eventId);
                return InkWell(
                  onTap: () {
                    if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                      if (eventId.isNotEmpty) {
                        if (isFav) {
                          context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: eventId, favType: FavType.odds));
                        } else {
                          context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: eventId, favType: FavType.odds));
                        }
                      }
                    } else {
                      desktopLoginView(context);
                    }
                  },
                  child: SizedBox(
                    width: 40,
                    child: Tooltip(
                      message: '${isFav ? 'Remove from' : 'Add to'} Multi Markets',
                      decoration: BoxDecoration(color: black),
                      child: SvgPicture.asset(colorFilter: ColorFilter.mode(isFav ? green : grey, BlendMode.srcIn), AppAssetConstants.pinblue, height: 20, width: 20),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SportsHighlightsHeader extends StatelessWidget {
  const SportsHighlightsHeader({super.key, this.type = 0, this.sid});

  final int type;
  final String? sid;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final showDraw = sid == "1" || sid == "4"; //1- soccer, 4- cricket
    final labels = showDraw ? ["1", "X", "2"] : (!horseAndGreyRacingEnabledForSid(sid ?? "0") ? ["1", "2"] : []);
    return BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
      builder: (context, state) {
        return Container(
          height: 25,
          width: size.width,
          decoration: BoxDecoration(color: type == 0 ? const Color(0xFFDDDCD6) : const Color(0xFFCED5DA)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(),
                          Row(children: [SizedBox()]),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text("", style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                    const VerticalDivider(color: Colors.transparent, width: 0.5),
                  ],
                ),
              ),

              // ✅ Labels row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(labels.length, (index) {
                  return Row(
                    children: [
                      Container(
                        width: size.width * 0.04 * 2,
                        alignment: Alignment.center,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black),
                        ),
                      ),
                      if (index != labels.length - 1) const VerticalDivider(color: Colors.transparent, width: 10),
                    ],
                  );
                }),
              ),

              const SizedBox(width: 40), // favorite icon space
            ],
          ),
        );
      },
    );
  }
}

class TimeForHorseAndGreyRacing extends StatelessWidget {
  const TimeForHorseAndGreyRacing({super.key, required this.event, this.action});

  final Event event;

  final void Function()? action;
  String _formatTimeOnly(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      // Format: "HH:MM" (24-hour format)
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: action,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 35,
            width: size.width * 0.045,
            decoration: BoxDecoration(color: event.inPlay ? Color(0xFF6BBD11) : Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: Text(_formatTimeOnly(event.openDate), style: TextStyle(fontSize: 14, color: event.inPlay ? white : black)),
            ),
          ),
        ),
      ),
    );
  }
}
