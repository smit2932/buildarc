import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BarShimmer extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final double height;
  final EdgeInsetsGeometry margin;

  const BarShimmer({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.height,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1400),
            child: Container(
              height: 20.0,
              margin: const EdgeInsets.only(right: 48.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
