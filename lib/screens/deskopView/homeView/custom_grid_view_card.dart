import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../reusables/cached_image.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/style.dart';
import '../../mobileScreens/mvReusables/home_card_with_image.dart';
import '../mainTabView/live_badge.dart';

class CustomHomeCard extends StatelessWidget {
  const CustomHomeCard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        children: [
          Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 6,
            child: Container(
              color: white,
              child: Column(children: children),
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }
}

class CustomGridViewCard extends StatelessWidget {
  const CustomGridViewCard({super.key, this.height, required this.children, this.count});
  final int? count;
  final double? height;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 10) / (count ?? 2);
        final double itemHeight = height ?? 230;
        final double aspectRatio = itemWidth / itemHeight;
        return GridView.count(
          crossAxisCount: (count ?? 2),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          children: children,
        );
      },
    );
  }
}

class CustomImageCardWithAction extends StatelessWidget {
  const CustomImageCardWithAction({super.key, required this.title, required this.action, required this.imgUrl, this.showPlayNowBtn = true, this.showCount = false});

  final String title;
  final void Function() action;
  final String imgUrl;
  final bool showPlayNowBtn;
  final bool showCount;
  @override
  Widget build(BuildContext context) {
    int cricket = 0, soccer = 0, tennis = 0;
    return InkWell(
      onTap: action,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(child: AssetsImageWithProgress(imgUrl: imgUrl)),
          if (showCount)
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
                    height: 130,
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
          // Gradient overlay (for readability of text)
          if (showPlayNowBtn)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: black.withValues(alpha: 0.7),
                  border: Border(bottom: BorderSide(color: appYellow, width: 7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: HighlightText(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: action,
                      child: Row(
                        children: [
                          ClipPath(
                            clipper: RightAngleTriangleClipper(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(gradient: playButtonGradient),
                              child: HighlightText(
                                " ",
                                style: const TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(gradient: playButtonGradient),
                            child: HighlightText(
                              "Play Now",
                              style: const TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildLiveCountRow(String title, int count) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: HighlightText(
          title,
          style: const TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        height: 25,
        width: 25,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(3)),
        child: Center(
          child: HighlightText(
            count.toString(),
            style: const TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}

class CustomImageCardWithActionForRG extends StatelessWidget {
  const CustomImageCardWithActionForRG({super.key, required this.title, required this.action, required this.imgUrl});

  final String title;
  final void Function() action;
  final String imgUrl;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(child: AssetsUrlImageWithProgress(imgUrl: imgUrl)),
          // Gradient overlay (for readability of text)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: black.withValues(alpha: 0.7),
                border: Border(bottom: BorderSide(color: appYellow, width: 7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: HighlightText(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: action,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipPath(
                          clipper: RightAngleTriangleClipper(),
                          child: Container(width: 15, height: 30, decoration: BoxDecoration(gradient: playButtonGradient)),
                        ),
                        Container(
                          decoration: BoxDecoration(gradient: playButtonGradient),
                          width: 75,
                          height: 30,
                          child: Center(
                            child: HighlightText(
                              "Play Now",
                              overflow: TextOverflow.ellipsis,
                              style: tStyle18.copyWith(color: black, overflow: TextOverflow.ellipsis, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MVCustomImageCardWithActionForRG extends StatelessWidget {
  const MVCustomImageCardWithActionForRG({super.key, required this.title, required this.action, required this.imgUrl});

  final String title;
  final void Function() action;
  final String imgUrl;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(child: AssetsUrlImageWithProgress(imgUrl: imgUrl)),
          // Gradient overlay (for readability of text)
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
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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
                              width: 75,
                              child: Center(
                                child: Text(
                                  "Play Now",
                                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
