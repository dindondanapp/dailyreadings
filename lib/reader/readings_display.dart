import 'package:dailyreadings/reader/alternative_control_widget.dart';
import 'package:dailyreadings/reader/section_widget.dart';
import 'package:flutter/material.dart';

import '../common/enums.dart';

/// A widget that displays the daily readings
class ReadingsDisplay extends StatefulWidget {
  final ReadingsData data;
  const ReadingsDisplay({Key key, @required this.data}) : super(key: key);

  @override
  _ReadingsDisplayState createState() => _ReadingsDisplayState();
}

class _ReadingsDisplayState extends State<ReadingsDisplay> {
  final globalAlternativeController = AlternativeController();

  /// Get the labels for alternative versions of the whole set of readings, if
  /// they exist. This happens when all the sections with alternatives have
  /// labeled alternatives, and the labels are the same for every section. Each
  /// label will correspond to a global alternative. Otherwise returns null.
  List<String> getGlobalAlternatives() {
    final sectionsWithAlternatives = widget.data.sections
        .where((element) => element.alternatives.length > 1)
        .toList();

    if (sectionsWithAlternatives.length <= 1 ||
        !sectionsWithAlternatives.every(
          (section) {
            final hasLabels = section.alternatives.every(
                (element) => element.label != null && element.label != '');

            final hasSameLabelsAsFirst = section.alternatives
                    .map((e) => e.label) ==
                sectionsWithAlternatives.first.alternatives.map((e) => e.label);
            return hasLabels && hasSameLabelsAsFirst;
          },
        )) {
      return null;
    }

    return sectionsWithAlternatives.first.alternatives
        .map((e) => e.label)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final globalAlternativeLabels = getGlobalAlternatives();
    final useGlobalAlternativeController = globalAlternativeLabels != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        useGlobalAlternativeController
            ? AlternativeSelectionBar(
                labels: globalAlternativeLabels,
                onSelected: (int index) =>
                    globalAlternativeController.value = index,
              )
            : Container(),
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
                widget.data.title,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize:
                        DefaultTextStyle.of(context).style.fontSize * 0.8),
              ),
            ],
          ),
        ),
        ...widget.data.sections
            .map((section) => SectionWidget(
                  section: section,
                  globalAlternativeController: useGlobalAlternativeController
                      ? globalAlternativeController
                      : null,
                ))
            .toList(),
      ],
    );
  }

  @override
  void dispose() {
    globalAlternativeController.dispose();
    super.dispose();
  }
}
