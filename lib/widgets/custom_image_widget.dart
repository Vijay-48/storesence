import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Icon(Icons.broken_image, size: 48, color: Colors.grey);
        },
      );
    }

    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Icon(Icons.broken_image, size: 48, color: Colors.grey);
        },
      );
    }

    return placeholder ?? const Icon(Icons.image, size: 48, color: Colors.grey);
  }
}
