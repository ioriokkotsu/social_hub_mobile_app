import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(T data) builder;

  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;
  final Widget? empty;

  final double? width;
  final double? height;
  
  final double? radius;

  const FirestoreStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.width,
    this.height,
    this.loading,
    this.errorBuilder,
    this.empty, this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? _defaultShimmer();
        }

        if (snapshot.hasError) {
          return errorBuilder != null
              ? errorBuilder!(snapshot.error!)
              : Center(child: Text("Error: ${snapshot.error}"));
        }

        final data = snapshot.data;

        if (data == null) {
          return empty ?? const Center(child: Text("No data"));
        }

        if (data is QuerySnapshot && data.docs.isEmpty) {
          return empty ?? const Center(child: Text("No data"));
        }
        return builder(data);
      },
    );
  }

  Widget _defaultShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Container(
            constraints: BoxConstraints(minWidth: width ?? 50, minHeight: height ?? 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}