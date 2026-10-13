import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';

class HitSlop extends SingleChildRenderObjectWidget {
  final double minHeight;
  final double minWidth;
  final Object? target;

  const HitSlop({
    super.key,
    this.minHeight = AppMetrics.minHitTarget,
    this.minWidth = AppMetrics.minHitTarget,
    this.target,
    required super.child,
  });

  @override
  RenderHitSlop createRenderObject(BuildContext context) =>
      RenderHitSlop(minHeight: minHeight, minWidth: minWidth, target: target);

  @override
  void updateRenderObject(BuildContext context, RenderHitSlop renderObject) {
    renderObject
      ..minHeight = minHeight
      ..minWidth = minWidth
      ..target = target;
  }
}

class RenderHitSlop extends RenderProxyBox {
  double minHeight;
  double minWidth;
  Object? target;

  RenderHitSlop({
    required this.minHeight,
    required this.minWidth,
    this.target,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    final slopX = math.max(0.0, (minWidth - size.width) / 2);
    final slopY = math.max(0.0, (minHeight - size.height) / 2);
    if (position.dx < -slopX ||
        position.dx >= size.width + slopX ||
        position.dy < -slopY ||
        position.dy >= size.height + slopY) {
      return false;
    }
    final inside = Offset(
      position.dx < 0 || position.dx >= size.width
          ? size.width / 2
          : position.dx,
      position.dy < 0 || position.dy >= size.height
          ? size.height / 2
          : position.dy,
    );
    if (target != null) {
      final probe = BoxHitTestResult();
      hitTestChildren(probe, position: inside);
      final onTarget = probe.path.any((e) =>
          e.target is RenderMetaData &&
          (e.target as RenderMetaData).metaData == target);
      if (!onTarget) return false;
    }
    if (!hitTestChildren(result, position: inside)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}
