import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/shimmer.dart';

class ClientCardSkeleton extends StatelessWidget {
  const ClientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 60, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 120, height: 11, radius: 5),
            Spacer(),
            ShimmerBox(width: 60, height: 11, radius: 5),
          ]),
        ]),
      ),
    );
  }
}

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: ShimmerBox(width: 160, height: 14, radius: 7)),
            SizedBox(width: 12),
            ShimmerBox(width: 70, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 100, height: 11, radius: 5),
            SizedBox(width: 12),
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 80, height: 11, radius: 5),
          ]),
          SizedBox(height: 8),
          Row(children: [
            ShimmerBox(width: 80, height: 13, radius: 6),
            SizedBox(width: 12),
            ShimmerBox(width: 90, height: 11, radius: 5),
          ]),
          SizedBox(height: 4),
          ShimmerBox(width: 110, height: 11, radius: 5),
        ]),
      ),
    );
  }
}

class MeetingCardSkeleton extends StatelessWidget {
  const MeetingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 44, height: 44, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 20, height: 20, radius: 4),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 160, height: 12, radius: 6),
            SizedBox(width: 12),
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 80, height: 12, radius: 6),
          ]),
        ]),
      ),
    );
  }
}

class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 44, height: 44, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 80, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 70, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 90, height: 16, radius: 8),
            Spacer(),
            ShimmerBox(width: 55, height: 11, radius: 5),
            SizedBox(width: 8),
            ShimmerBox(width: 60, height: 11, radius: 5),
          ]),
          SizedBox(height: 6),
          Row(children: [
            ShimmerBox(width: 13, height: 13, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 180, height: 11, radius: 5),
          ]),
        ]),
      ),
    );
  }
}
