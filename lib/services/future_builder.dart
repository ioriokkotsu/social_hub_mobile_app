import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FirestoreFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;

  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;
  final Widget? empty;
  
  final double? width;
  final double? height;

  const FirestoreFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.width,
    this.height,
    this.loading,
    this.errorBuilder,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? _defaultShimmer();
        }

        if (snapshot.hasError) {
          return errorBuilder != null
              ? errorBuilder!(snapshot.error!)
              : Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return empty ?? const Center(child: Text("No data"));
        }

        final data = snapshot.data as T;

        if (data is List && data.isEmpty) {
          return empty ?? const Center(child: Text("No data"));
        }

        return builder(data);
      },
    );
  }

  Widget _defaultShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final fallbackHeight = constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 48.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              width: width ?? fallbackWidth,
              height: height ?? fallbackHeight,
            ),
          ),
        );
      },
    );
  }
}