import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../apis/apiHandlers/api_constants.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_cg_category_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../constants/lists/home_screen_lists.dart';
import '../../../constants/strings/home_screen_strings.dart';
import '../../../demo/services/demo_session.dart';
import '../../../models/cg_model.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/navigators.dart';
import '../../deskopView/homeView/custom_carousel.dart';
import '../../deskopView/homeView/custom_grid_view_card.dart';
import '../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../mvAccounts/cgaming/show_cg_add_money_dialog.dart';
import '../mvReusables/custom_card.dart';
import '../mvReusables/home_card_with_image.dart';

class MvHomeScreen extends StatefulWidget {
  const MvHomeScreen({super.key});

  @override
  State<MvHomeScreen> createState() => _MvHomeScreenState();
}

class _MvHomeScreenState extends State<MvHomeScreen> {
  @override
  void initState() {
    context.read<FetchOnlyInplayCountsBloc>().add(FetchOnlyInplayCounts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('mv-home-scroll-view'),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: 120, child: CustomCarousel(isMobile: true, imagesList: homeBanner)),
        ),
        SliverToBoxAdapter(
          child: HomeCardWithImage(
            action: () {
              context.go(GoToRoute.sport(name: 'Cricket', sportId: "4"));
            },
            imageList: sportsImage,
            title: HomeScreenStrings.sports,
            buttonTitle: HomeScreenStrings.playNow,
          ),
        ),
        BlocBuilder<FetchCGCategoryBloc, FetchCGCategoryState>(
          builder: (context, cgs) {
            List<CGData> cGData = [];
            if (cgs is FetchCGCategorySuccess) {
              cGData = cgs.cGData;
            }
            if (cGData.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 1.35),
                itemCount: cGData.length,
                itemBuilder: (context, index) {
                  final sp = cGData[index];
                  return MVCustomImageCardWithActionForRG(
                    imgUrl: "${CGApiConstants.baseUrlCasino}${sp.urlThumb}",
                    title: sp.gameName,
                    action: () {
                      if (DemoSession.isActive) {
                        showSnackBar(context, "This option is disabled in Demo Mode. Use Live Account.", error: true);
                      } else {
                        final authState = context.read<UserAuthChangesBloc>().state;
                        if (authState is UserAuthChangesSuccess && authState.savedUserAuth == null) {
                          pushSimple(context, MVLogin());
                        } else {
                          context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
                          showCgAddMoneyDialog(context, sp);
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: CustomContactCard()),
        SliverToBoxAdapter(child: hb10),
      ],
    );
  }
}
