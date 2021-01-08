import 'package:dailyreadings/common/enums.dart';
import 'package:flutter/material.dart';

import 'block_widget.dart';

class SectionWidget extends StatefulWidget {
  final Section section;
  final bool showAlternativeControl;

  const SectionWidget(
      {Key key, @required this.section, this.showAlternativeControl = true})
      : super(key: key);
  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.section.alternatives
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
          .toList(),
    );
  }
}
