import 'package:cached_network_image/cached_network_image.dart';
import 'package:evelink/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// A widget that displays an image from a private Backblaze B2 bucket by
/// handling the necessary authorization headers and caching the image.
class PrivateNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final String? seedForFallbackColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const PrivateNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.seedForFallbackColor,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Use the CachedNetworkImage widget with our custom B2CacheManager.
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: B2CacheManager(), // This is our custom manager
      fit: fit,
      placeholder: (context, url) =>
      placeholder ??
          Container(
            color: Helpers.getRandomColor(seedForFallbackColor ?? 'default')
                .withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) =>
      errorWidget ??
          Container(
            color: Colors.grey.shade200,
            child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red)),
          ),
    );
  }
}