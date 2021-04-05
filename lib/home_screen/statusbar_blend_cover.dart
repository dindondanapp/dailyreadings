import 'package:flutter/material.dart';

/// Just a simple widget that creates a soft gradient between the status bar and the scrollable content
class StatusBarBlendCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Status bar height
    final paddingTop = MediaQuery.of(context).padding.top;

    // How much it should extend below the status bar
    final offset = 20;

    // Where the gradient should start with respect to the end of the status bar
    final gradientStartOffset = -10;

    return IgnorePointer(
      // No gesture interaction
      child: Container(
        height: paddingTop + offset,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(
                0,
                (paddingTop + gradientStartOffset) / (paddingTop + offset) * 2 -
                    1),
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}
