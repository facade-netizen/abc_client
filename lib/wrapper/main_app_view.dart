import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../blocs/authBlocs/user_auth_change_bloc.dart';
import '../blocs/fetchBlocs/fetch_cg_category_bloc.dart';
import '../blocs/fetchBlocs/fetch_news_announcements_bloc.dart';
import '../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../blocs/fetchBlocs/fetch_wl_details_bloc.dart';
import '../blocs/miscBlocs/user_ip_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/news_signalr_bloc.dart';
import '../constants/app_string_constants.dart';
import '../reusables/custom_app_theme.dart';
import '../routing/app_router.dart';

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  @override
  void initState() {
    super.initState();
    context.read<UserIPBloc>().add(UserIP());
    context.read<NewsSRBloc>().add(ConnectNewsSR());
    context.read<FetchCGCategoryBloc>().add(FetchCGCategory(page: 1, pageSize: 25));
    context.read<FetchSportsCategoryBloc>().add(FetchSportsCategory());
    context.read<FetchNewsAnnouncementsBloc>().add(FetchNewsAnnouncements());
    context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchWlDetailsBloc, FetchWlDetailsState>(
      listenWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is FetchWlDetailsSuccess && current is FetchWlDetailsSuccess ) {
          return previous.appData.inMaintenance != current.appData.inMaintenance;
        }
        return false;
      },
      listener: (context, state) {
        appRouter.refresh();
      },
      child: BlocListener<UserAuthChangesBloc, UserAuthChangesState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            (previous is UserAuthChangesSuccess && current is UserAuthChangesSuccess && previous.savedUserAuth?.userId != current.savedUserAuth?.userId),
        listener: (context, state) {
          appRouter.refresh();
        },
        child: MaterialApp.router(
          routerConfig: appRouter,
          title: AppStringConstants.appName.toUpperCase(),
          debugShowCheckedModeBanner: false,
          theme: customAppTheme,
          localizationsDelegates: const [GlobalWidgetsLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        ),
      ),
    );
  }
}
