import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants/app_asset_constants.dart';
import '../../../reusables/cached_image.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/responsive.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({
    super.key,
    required this.imagesList,
    this.isMobile = false,
  });
  final List<String> imagesList;
  final bool isMobile;

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  late final PageController carouselController;
  int currentCarousel = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    carouselController = PageController();
    startAutoScroll();
  }

  @override
  void dispose() {
    carouselController.dispose();
    timer.cancel();
    super.dispose();
  }

  void startAutoScroll() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      carouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.isTablet(context) ? 280 : (widget.isMobile ? 150 : 300),
      child: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: carouselController,
            itemCount: widget.imagesList.length * 100,
            onPageChanged: (int currCarousel) {
              setState(() {
                currentCarousel = currCarousel % widget.imagesList.length;
              });
            },
            itemBuilder: (context, index) {
              return AssetsImageWithProgress(imgUrl: widget.imagesList[index % widget.imagesList.length]);
            },
          ),
          CarouselButton(
            previousAction: currentCarousel == 0
                ? null
                : () {
                    carouselController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
            nextAction: currentCarousel == widget.imagesList.length - 1
                ? null
                : () {
                    carouselController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
          ),
        ],
      ),
    );
  }
}

class CarouselButton extends StatelessWidget {
  const CarouselButton({
    super.key,
    this.nextAction,
    this.previousAction,
  });
  final void Function()? nextAction;
  final void Function()? previousAction;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: previousAction,
              icon: const Icon(Icons.arrow_back_ios, color: whiteOpac),
            ),
            IconButton(
              onPressed: nextAction,
              icon: const Icon(Icons.arrow_forward_ios, color: whiteOpac),
            ),
          ],
        ),
      ),
    );
  }
}

///
class FadeImageChangeBanner extends StatefulWidget {
  final List<String> images;

  const FadeImageChangeBanner({super.key, required this.images});

  @override
  FadeImageChangeBannerState createState() => FadeImageChangeBannerState();
}

class FadeImageChangeBannerState extends State<FadeImageChangeBanner> {
  late int currentIndex;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.images.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: FadeInImage.assetNetwork(
        fit: BoxFit.fill,
        width: double.infinity,
        filterQuality: FilterQuality.high,
        placeholder: AppAssetConstants.darkBg,
        image: widget.images[currentIndex],
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }
}
