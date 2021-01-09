import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Custom scroll physiscs for the main scroll view
class HomeScrollPhysics extends ScrollPhysics {
  final double controlsBoxSize;

  /// Creates custom scroll physiscs for the main scroll view
  const HomeScrollPhysics(
      {@required this.controlsBoxSize, ScrollPhysics parent})
      : super(parent: parent);

  @override
  HomeScrollPhysics applyTo(ScrollPhysics ancestor) {
    return HomeScrollPhysics(
        controlsBoxSize: controlsBoxSize, parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ([0, controlsBoxSize].contains(position.pixels) && velocity == 0) {
      return super.createBallisticSimulation(position, velocity);
    } else {
      if (position.pixels < controlsBoxSize / 2) {
        return ScrollSpringSimulation(spring, position.pixels, 0, velocity,
            tolerance: tolerance);
      } else if (position.pixels >= controlsBoxSize / 2 &&
          position.pixels < controlsBoxSize) {
        return ScrollSpringSimulation(
            spring, position.pixels, controlsBoxSize, velocity,
            tolerance: tolerance);
      } else if (position.pixels < position.maxScrollExtent && velocity != 0) {
        return BoundedFrictionSimulation(0.15, position.pixels, velocity,
            controlsBoxSize, position.maxScrollExtent);
      } else {
        return super.createBallisticSimulation(position, velocity);
      }
    }
  }

  @override
  bool get allowImplicitScrolling => false;
}
