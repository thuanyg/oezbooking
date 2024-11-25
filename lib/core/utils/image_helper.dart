import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageHelper {
  static Widget loadAssetImage(String imageAssetPath,
      {double? width,
      double? height,
      BorderRadius? radius,
      Color? tintColor,
      Alignment? alignment,
      BoxFit? fit}) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Image.asset(
        imageAssetPath,
        width: width,
        height: height,
        fit: fit,
        color: tintColor,
        alignment: alignment ?? Alignment.center,
      ),
    );
  }

  static Widget loadNetworkImage(
    String imageLink, {
    double? width,
    double? height,
    BorderRadius? radius,
    Color? tintColor,
    Alignment alignment = Alignment.center,
    BoxFit? fit,
  }) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageLink,
        placeholder: (context, url) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          );
        },
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error, color: Colors.red)),
        width: width,
        height: height,
        alignment: alignment,
        fit: fit,
      ),
    );
  }

  static Widget loadSvgImage(
      String svgPath, {
        double? width,
        double? height,
        Color? tintColor,
        BoxFit fit = BoxFit.contain,
        Alignment alignment = Alignment.center,
      }) {
    return SvgPicture.asset(
      svgPath,
      width: width,
      height: height,
      color: tintColor,
      fit: fit,
      alignment: alignment,
    );
  }

  static Widget loadNetworkSvgImage(
      String svgUrl, {
        double? width,
        double? height,
        Color? tintColor,
        BoxFit fit = BoxFit.contain,
        Alignment alignment = Alignment.center,
      }) {
    return SvgPicture.network(
      svgUrl,
      width: width,
      height: height,
      color: tintColor,
      fit: fit,
      alignment: alignment,
      placeholderBuilder: (BuildContext context) => const Center(
        child: CircularProgressIndicator(color: Colors.grey),
      ),
    );
  }
}
