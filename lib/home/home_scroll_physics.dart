import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Custom scroll physiscs for the main scroll view
class HomeScrollPhysics extends ScrollPhysics {
  final double bound;

  /// Creates custom scroll physiscs for the main scroll view
  const HomeScrollPhysics({@required this.bound, ScrollPhysics parent})
      : super(parent: parent);

  @override
  HomeScrollPhysics applyTo(ScrollPhysics ancestor) {
    return HomeScrollPhysics(bound: bound, parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ([0, bound].contains(position.pixels) && velocity == 0) {
      return super.createBallisticSimulation(position, velocity);
    } else {
      if (position.pixels < bound / 2) {
        return ScrollSpringSimulation(spring, position.pixels, 0, velocity,
            tolerance: tolerance);
      } else if (position.pixels >= bound / 2 && position.pixels < bound) {
        return ScrollSpringSimulation(spring, position.pixels, bound, velocity,
            tolerance: tolerance);
      } else if (position.pixels < position.maxScrollExtent && velocity != 0) {
        return BoundedFrictionSimulation(
            0.15, position.pixels, velocity, bound, position.maxScrollExtent);
      } else {
        return super.createBallisticSimulation(position, velocity);
      }
    }
  }

  @override
  bool get allowImplicitScrolling => false;
}
