import 'package:flutter/material.dart';

import 'asset_paths.dart';

/// Helper class to load images with error handling
class AppImages {
  /// Load an image asset with a placeholder on error
  static Widget asset(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  /// Load a network image with a placeholder on error
  static Widget network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  /// App logo image
  static Widget logo({double? width, double? height}) {
    return asset(
      AssetPaths.appLogo,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  /// Placeholder image
  static Widget placeholder({double? width, double? height}) {
    return asset(
      AssetPaths.placeholder,
      width: width,
      height: height,
    );
  }
}
