import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui;

import 'loader.dart';

class CachedImageWithProgress extends StatelessWidget {
  const CachedImageWithProgress({super.key, required this.imgUrl});
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.fill,
      width: double.infinity,
      filterQuality: FilterQuality.high,
      imageUrl: imgUrl,
      errorWidget: (context, url, error) {
        return const Icon(Icons.error);
      },
    );
  }
}

CachedNetworkImageProvider cachedNetworkImageProvider(String imageUrl) {
  return CachedNetworkImageProvider(imageUrl);
}

class LoadingFileScreen extends StatelessWidget {
  const LoadingFileScreen({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    return const LoaderContainerWithMessage(message: "");
  }
}

class AssetsImageWithProgress extends StatelessWidget {
  const AssetsImageWithProgress({super.key, required this.imgUrl});
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imgUrl,
      fit: BoxFit.fill,
      width: double.infinity,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }
}

class AssetsUrlImageWithProgress extends StatelessWidget {
  const AssetsUrlImageWithProgress({super.key, required this.imgUrl});
  final String imgUrl;
  static final Set<String> _registeredViewIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final String viewId = 'image-${imgUrl.hashCode}';
    if (!_registeredViewIds.contains(viewId)) {
      _registeredViewIds.add(viewId);
      ui.platformViewRegistry.registerViewFactory(
        viewId,
        (int viewId) {
          final img = html.ImageElement()
            ..src = imgUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'fill';
          return img;
        },
      );
    }
    return SizedBox(
      width: double.infinity,
      child: HtmlElementView(viewType: viewId),
    );
  }
}
