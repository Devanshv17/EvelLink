import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/services.dart';
import '../utils/utils.dart';

/// A widget that displays an image from a private Backblaze B2 bucket by
/// handling the necessary authorization headers.
class PrivateNetworkImage extends StatefulWidget {
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
  State<PrivateNetworkImage> createState() => _PrivateNetworkImageState();
}

class _PrivateNetworkImageState extends State<PrivateNetworkImage> {
  // Use a Future to hold the state of the image fetch operation.
  late Future<Uint8List?> _imageFuture;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Start fetching the image data when the widget is first created.
    _imageFuture = _storageService.fetchPrivateImageData(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        // While waiting for the image, show a placeholder.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ??
              Container(
                color: Helpers.getRandomColor(widget.seedForFallbackColor ?? 'default').withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              );
        }

        // If the fetch fails or returns no data, show an error icon.
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return widget.errorWidget ??
              Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
              );
        }

        // If data is successfully fetched, display it using Image.memory.
        return Image.memory(
          snapshot.data!,
          fit: widget.fit,
        );
      },
    );
  }
}