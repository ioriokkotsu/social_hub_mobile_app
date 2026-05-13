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

        /// 🔹 LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? _defaultShimmer();
        }

        /// 🔹 ERROR
        if (snapshot.hasError) {
          return errorBuilder != null
              ? errorBuilder!(snapshot.error!)
              : Center(child: Text("Error: ${snapshot.error}"));
        }

        final data = snapshot.data;

        /// 🔹 NO DATA
        if (data == null) {
          return empty ?? const Center(child: Text("No data"));
        }

        /// 🔹 HANDLE FIRESTORE QUERY EMPTY
        if (data is QuerySnapshot && data.docs.isEmpty) {
          return empty ?? const Center(child: Text("No data"));
        }
        /// 🔹 SUCCESS
        return builder(data);
      },
    );
  }

  Widget _defaultShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth = width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : 120.0);
        final resolvedHeight = height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : 40.0);

        return SizedBox(
          width: resolvedWidth.isFinite ? resolvedWidth : 120.0,
          height: resolvedHeight.isFinite ? resolvedHeight : 40.0,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 10),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      },
    );
  }
}