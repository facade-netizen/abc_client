import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_mm_fancy_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_user_mm_fancy_pl_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_bm_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_fancy_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_odds_signalr_streamer.dart';
import '../../../models/fav_stake_model.dart';
import '../../../models/favourite_model.dart';
import '../../../models/mm_fancy_model.dart';
import 'multi_market_view.dart';

class MultiMarketViewStreamer extends StatefulWidget {
  const MultiMarketViewStreamer({super.key});

  @override
  State<MultiMarketViewStreamer> createState() => _MultiMarketViewStreamerState();
}

class _MultiMarketViewStreamerState extends State<MultiMarketViewStreamer> {
  List<FavouriteEventData> favEvents = [];
  FavStakeData? favStakeData;
  List<List<MMFancyMarketData>> fancyMarketData = [];
  @override
  void initState() {
    context.read<FetchFavouriteBloc>().add(FetchFavourite());
    context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
    context.read<FetchUserMMFancyPLBloc>().add(FetchUserMMFancyPL());
    context.read<FetchMMFancyBloc>().add(FetchMMFancy());
    context.read<SignalRMMODDSDataBloc>().add(SignalRMMODDSDataListener());
    context.read<SignalRMMBMDataBloc>().add(SignalRMMBMDataListener());
    context.read<SignalRMMFancyDataBloc>().add(SignalRMMFancyDataListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
      listener: (context, afe) {
        if (afe is AddFavouriteEventsSuccess) {
          context.read<FetchFavouriteBloc>().add(FetchFavourite());
        }
      },
      child: BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
        listener: (context, rfe) {
          if (rfe is RemoveFavouriteEventsSuccess) {
            context.read<FetchFavouriteBloc>().add(FetchFavourite());
            context.read<FetchMMFancyBloc>().add(FetchMMFancy());
          }
        },
        child: BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
          builder: (context, state) {
            return BlocBuilder<FetchMMFancyBloc, FetchMMFancyState>(
              builder: (context, mmf) {
                return BlocBuilder<FetchFavouriteBloc, FetchFavouriteState>(
                  builder: (context, ffs) {
                    if (ffs is FetchFavouriteSuccess) {
                      favEvents = ffs.favEvents;
                    }
                    if (state is FetchFavStakeSuccess) {
                      favStakeData = state.favStakeData;
                    }
                    if (mmf is FetchMMFancySuccess) {
                      fancyMarketData = mmf.fancyMarketData;
                    }
                    return MultiMarketView(
                      key: ValueKey("multi_market_view_at_${DateTime.now().millisecondsSinceEpoch}"),
                      favEvents: favEvents,
                      favStakeData: favStakeData,
                      fancyMarketData: fancyMarketData,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
