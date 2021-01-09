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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        labels == null
            ? AlternativeControlWidget(
                labels: labels,
                onSelected: (int index) => alternativeController.value = index,
              )
            : Container(),
        ...widget.section.alternatives
            .map(
              (alternative) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: alternative.blocks.map(
                  (block) {
                    const dropCapSections = [
                      SectionType.rLectioPrima,
                      SectionType.rLectioSecunda,
                      SectionType.rEvangelium,
                      SectionType.aEpistula,
                      SectionType.aLectio,
                      SectionType.aEvangelium,
                    ];
                    final dropCap =
                        dropCapSections.contains(widget.section.name) &&
                            block ==
                                alternative.blocks.firstWhere(
                                    (el) => el.type == BlockType.Text,
                                    orElse: () => null);
                    return BlockWidget(
                      block: block,
                      dropCap: dropCap,
                    );
                  },
                ).toList(),
              ),
            )
            .toList()
      ],
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
