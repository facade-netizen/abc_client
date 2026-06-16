import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../apis/apiHandlers/api_constants.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_cg_category_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../constants/app_string_constants.dart';
import '../../../demo/services/demo_session.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../models/cg_model.dart';
import '../../../reusables/open_url.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../authView/desktop_login_view.dart';
import '../betRadarView/bet_radar_view.dart';
import 'custom_carousel.dart';
import 'custom_footer_card.dart';
import 'custom_grid_view_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomHomeCard(
      children: [
        CustomCarousel(imagesList: homeBanner),
        hb15,
        //sports cards 2*2
        CustomGridViewCard(
          children: sportsTwoByTwo.map((sports) {
            return CustomImageCardWithAction(
              showPlayNowBtn: sports["title"]?.toLowerCase() != "kabaddi",
              showCount: sports["title"]?.toLowerCase() != "kabaddi",
              action: () async {
                if (sports["title"]?.toLowerCase() == "kabaddi") {
                  await openUrl(AppStringConstants.whatsappLink1);
                } else {
                  context.go('/inplay');
                }
              },
              imgUrl: sports["image"] ?? "",
              title: sports["title"] ?? "",
            );
          }).toList(),
        ),
        hb15,
        BlocBuilder<FetchCGCategoryBloc, FetchCGCategoryState>(
          builder: (context, cgs) {
            List<CGData> cGData = [];
            if (cgs is FetchCGCategorySuccess) {
              cGData = cgs.cGData;
            }
            if (cGData.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: cGData.asMap().entries.map((entry) {
                    final sp = entry.value;
                    final crossAxisCellCount = (sp.category.toLowerCase().contains('lobby')) ? 2 : 1;
                    return StaggeredGridTile.count(
                      crossAxisCellCount: crossAxisCellCount,
                      mainAxisCellCount: 1,
                      child: BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                        builder: (context, ucs) {
                          SaveLoginTokenModel? userLogedinSaveData;
                          if (ucs is UserAuthChangesSuccess) {
                            userLogedinSaveData = ucs.savedUserAuth;
                          }

                          return CustomImageCardWithActionForRG(
                            imgUrl: "${CGApiConstants.baseUrlCasino}${sp.urlThumb}",
                            title: sp.gameName,
                            action: () {
                              if (DemoSession.isActive) {
                                showSnackBar(context, "This option is disabled in Demo Mode. Use Live Account.", error: true);
                              } else {
                                if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                  betRadarView(context, sp);
                                } else {
                                  desktopLoginView(context);
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        hb15,
        CustomFooterCard(type: 0, isshowOneClickBetFooterCard: true),
      ],
    );
  }
}
