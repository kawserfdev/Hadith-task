import 'package:flutter/material.dart';

class PerformanceUtils {
  // Cache images
  static ImageProvider cacheNetworkImage(String url) {
    return NetworkImage(url, scale: 1.0);
  }
  
  // Lazy loading list view
  static Widget lazyListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required ScrollController controller,
  }) {
    return ListView.builder(
      controller: controller,
      itemCount: itemCount,
      // Only render visible items to improve performance
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: itemBuilder,
    );
  }
}