import 'package:dailyreadings/common/enums.dart';
import 'package:dailyreadings/reader/alternative_control_widget.dart';
import 'package:flutter/material.dart';

import 'block_widget.dart';

class SectionWidget extends StatefulWidget {
  final Section section;
  final AlternativeController globalAlternativeController;

  const SectionWidget(
      {Key key, @required this.section, this.globalAlternativeController})
      : super(key: key);
  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  AlternativeController alternativeController;
  @override
  void initState() {
    alternativeController =
        widget.globalAlternativeController ?? AlternativeController();

    super.initState();
  }

  List<String> getLabels() {
    return widget.section.alternatives
        .asMap()
        .map<int, String>(
          (index, alternative) => MapEntry(
            index,
            alternative.label ?? 'Alternativa ${index + 1}',
          ),
        )
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final labels =
        widget.globalAlternativeController == null ? getLabels() : null;
    print(labels.join(', '));
    return ValueListenableBuilder<int>(
      valueListenable: alternativeController,
      builder: (BuildContext context, int index, Widget _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          labels != null && labels.length >= 2
              ? AlternativeControlWidget(
                  labels: labels,
                  selected: index,
                  onSelected: (int selected) =>
                      alternativeController.value = selected,
                )
              : Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.section.alternatives[index].blocks.map(
              (block) {
                const dropCapSections = [
                  SectionType.rLectioPrima,
                  SectionType.rLectioSecunda,
                  SectionType.rEvangelium,
                  SectionType.aEpistula,
                  SectionType.aLectio,
                  SectionType.aEvangelium,
                ];
                final dropCap = dropCapSections.contains(widget.section.name) &&
                    block ==
                        widget.section.alternatives[index].blocks.firstWhere(
                            (el) => el.type == BlockType.Text,
                            orElse: () => null);
                return BlockWidget(
                  block: block,
                  dropCap: dropCap,
                );
              },
            ).toList(),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.globalAlternativeController == null) {
      alternativeController.dispose();
    }
    super.dispose();
  }
}

class AlternativeController extends ValueNotifier<int> {
  AlternativeController([int value]) : super(value ?? 0);
}
