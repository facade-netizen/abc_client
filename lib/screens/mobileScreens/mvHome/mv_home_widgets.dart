import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

class MVCustomGridViewCard extends StatelessWidget {
  const MVCustomGridViewCard({super.key, this.height, required this.children, this.count});
  final int? count;
  final double? height;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossCount = count ?? (constraints.maxWidth >= 1000 ? 4 : (constraints.maxWidth >= 800 ? 3 : 2));
        final double horizontalSpacing = 10;
        final double itemWidth = (constraints.maxWidth - (horizontalSpacing * (crossCount - 1))) / crossCount;
        final double itemHeight = height ?? (constraints.maxWidth >= 800 ? 230 : 170);
        final double aspectRatio = itemWidth / itemHeight;
        return GridView.count(
          crossAxisCount: crossCount,
          crossAxisSpacing: horizontalSpacing,
          mainAxisSpacing: horizontalSpacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          children: children,
        );
      },
    );
  }
}

class MVCustomImageCardWithAction extends StatelessWidget {
  const MVCustomImageCardWithAction({super.key, required this.title, required this.action, required this.imgUrl});
  final String title;
  final void Function() action;
  final String imgUrl;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Stack(
        children: [
          Positioned.fill(child: Image.network(imgUrl, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: action,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: const BoxDecoration(
                          color: appYellow,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
                        ),
                        child: Text(
                          "Play Now",
                          style: const TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.bold),
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
