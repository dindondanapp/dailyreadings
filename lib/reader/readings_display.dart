import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/entities.dart';
import 'alternative_control_widget.dart';
import 'section_widget.dart';

/// A widget that displays the daily readings
class ReadingsDisplay extends StatefulWidget {
  final ReadingsData data;
  const ReadingsDisplay({Key key, @required this.data}) : super(key: key);

  @override
  _ReadingsDisplayState createState() => _ReadingsDisplayState();
}

class _ReadingsDisplayState extends State<ReadingsDisplay> {
  AlternativeController globalAlternativeController;

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
            final hasSameLabelsAsFirst = ListEquality().equals(
                section.alternatives.map((e) => e.label).toList(),
                sectionsWithAlternatives.first.alternatives
                    .map((e) => e.label)
                    .toList());
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
  void didChangeDependencies() {
    globalAlternativeController = AlternativeController();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final globalAlternativeLabels = getGlobalAlternatives();
    final useGlobalAlternativeController = globalAlternativeLabels != null;

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
                widget.data.title,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize:
                        DefaultTextStyle.of(context).style.fontSize * 0.8),
              ),
            ],
          ),
        ),
        useGlobalAlternativeController
            ? ValueListenableBuilder<int>(
                valueListenable: globalAlternativeController,
                builder: (context, index, widget) {
                  return AlternativeSelectionBar(
                    labels: globalAlternativeLabels,
                    selected: index,
                    onSelected: (int index) =>
                        globalAlternativeController.value = index,
                  );
                })
            : Container(),
        ...widget.data.sections
            .map((section) => SectionWidget(
                  section: section,
                  globalAlternativeController: useGlobalAlternativeController
                      ? globalAlternativeController
                      : null,
                ))
            .toList(),
        SizedBox(height: 40),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Questi testi sono stati gentilmente offerti da ',
            children: [
              widget.data.sourceURL == null
                  ? TextSpan(
                      text: widget.data.source ?? '',
                    )
                  : TextSpan(
                      text: widget.data.source ?? '',
                      style: TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(widget.data.sourceURL.toString());
                        },
                    ),
            ],
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: DefaultTextStyle.of(context).style.fontSize * 0.8),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    globalAlternativeController.dispose();
    super.dispose();
  }
}
