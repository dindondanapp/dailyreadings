import 'package:dailyreadings/reader/section_widget.dart';
import 'package:flutter/material.dart';

import '../common/enums.dart';

/// A widget that displays the daily readings
class ReadingsDisplay extends StatelessWidget {
  final ReadingsData data;
  const ReadingsDisplay({Key key, @required this.data}) : super(key: key);

  /// Whether the readings should be displayed with alternative versions of the
  /// whole set of readings, instead of alternative versions for the single
  /// sections. This is done when all the sections with alternatives has
  /// labeled alternatives, and the labels are the same for every section. Each
  /// label will correspond to a global alternative.
  bool get dataHasGlobalAlternatives {
    final sectionsWithAlternatives = data.sections
        .where((element) => element.alternatives.length > 1)
        .toList();

    return sectionsWithAlternatives.length > 1 &&
        sectionsWithAlternatives.every(
          (section) {
            final hasLabels = section.alternatives.every(
                (element) => element.label != null && element.label != '');

            final hasSameLabelsAsFirst = section.alternatives
                    .map((e) => e.label) ==
                sectionsWithAlternatives.first.alternatives.map((e) => e.label);
            return hasLabels && hasSameLabelsAsFirst;
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final globalAlternativeControl = dataHasGlobalAlternatives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
              bottom: DefaultTextStyle.of(context).style.fontSize),
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize:
                        DefaultTextStyle.of(context).style.fontSize * 0.8),
              ),
            ],
          ),
        ),
        ...data.sections
            .map((section) => SectionWidget(
                  section: section,
                  showAlternativeControl: !globalAlternativeControl,
                ))
            .toList(),
      ],
    );
  }
}
