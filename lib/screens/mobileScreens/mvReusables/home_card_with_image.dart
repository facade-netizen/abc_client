import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../reusables/responsive.dart';
import '../../../reusables/style.dart';
import '../../../reusables/colors.dart';
import '../../deskopView/homeView/custom_carousel.dart';
import '../../deskopView/mainTabView/live_badge.dart';

class HomeCardWithImage extends StatelessWidget {
  const HomeCardWithImage({super.key, this.height, required this.title, required this.action, required this.buttonTitle, required this.imageList});

  final String title;
  final double? height;
  final String buttonTitle;
  final void Function() action;
  final List<String> imageList;

  @override
  Widget build(BuildContext context) {
    int cricket = 0, soccer = 0, tennis = 0;
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
      child: SizedBox(
        height: Responsive.isTablet(context) ? 280 : (height ?? 160),
        child: InkWell(
          onTap: action,
          child: Stack(
            children: [
              FadeImageChangeBanner(images: imageList),
              BlocBuilder<FetchOnlyInplayCountsBloc, FetchOnlyInplayCountsState>(
                builder: (context, state) {
                  if (state is FetchOnlyInplayCountsSuccess) {
                    cricket = state.cricketCount;
                    soccer = state.soccerCount;
                    tennis = state.tennisCount;
                  }
                  return Positioned(
                    right: 0,
                    child: Container(
                      height: 120,
                      width: 120,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [black.withValues(alpha: 0.8), black.withValues(alpha: 0.2)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiveBadgeWithTitle(liveTitle: "Live"),
                          const SizedBox(height: 8),
                          _buildLiveCountRow('Cricket', cricket),
                          const SizedBox(height: 4),
                          _buildLiveCountRow('Soccer', soccer),
                          const SizedBox(height: 4),
                          _buildLiveCountRow('Tennis', tennis),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: black.withValues(alpha: 0.7),
                    border: Border(bottom: BorderSide(color: appYellow, width: 4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          title,
                          style: TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: InkWell(
                          onTap: action,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ClipPath(
                                  clipper: RightAngleTriangleClipper(),
                                  child: Container(width: 15, decoration: BoxDecoration(gradient: playButtonGradient)),
                                ),
                                Container(
                                  decoration: BoxDecoration(gradient: playButtonGradient),
                                  width: 80,
                                  child: Center(
                                    child: Text(
                                      buttonTitle,
                                      maxLines: 1,
                                      style: tStyle18.copyWith(color: black, overflow: TextOverflow.ellipsis, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCountRow(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          height: 20,
          width: 25,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(3)),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class RightAngleTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
