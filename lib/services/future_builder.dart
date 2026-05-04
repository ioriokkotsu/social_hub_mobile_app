import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FirestoreFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;

  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;
  final Widget? empty;

  const FirestoreFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.errorBuilder,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {

        // 🔄 loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? _defaultShimmer();
        }

        // ❌ error
        if (snapshot.hasError) {
          return errorBuilder != null
              ? errorBuilder!(snapshot.error!)
              : Center(child: Text("Error: ${snapshot.error}"));
        }

        // 📭 empty
        if (!snapshot.hasData) {
          return empty ?? const Center(child: Text("No data"));
        }

        // ✅ success
        return builder(snapshot.data as T);
      },
    );
  }

  // 🔥 default shimmer (better than fixed height=10)
  Widget _defaultShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade600,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 120, height: 14),
            const SizedBox(height: 8),
            _shimmerBox(width: double.infinity, height: 10),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
    );
  }
}