import 'package:dailyreadings/common/entities.dart';
import 'package:dailyreadings/reader/alternative_control_widget.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';
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

  bool get canHaveDropCap {
    const dropCapSections = [
      SectionType.rLectioPrima,
      SectionType.rLectioSecunda,
      SectionType.rEvangelium,
      SectionType.aEpistula,
      SectionType.aLectio,
      SectionType.aEvangelium,
    ];
    return dropCapSections.contains(widget.section.name);
  }

  @override
  Widget build(BuildContext context) {
    final labels =
        widget.globalAlternativeController == null ? getLabels() : null;

    return ValueListenableBuilder<int>(
      valueListenable: alternativeController,
      builder: (BuildContext context, int index, Widget _) {
        final satIndex =
            index.sat(lower: 0, upper: widget.section.alternatives.length - 1);
        final blocks = widget.section.alternatives[satIndex].blocks;
        final dropCapBlock = canHaveDropCap
            ? blocks.firstWhere((el) => el.type == BlockType.Text,
                orElse: () => null)
            : null;
        final List<Widget> blockWidgets =
            _buildBlockWidgets(blocks, dropCapBlock);
        if (labels != null && labels.length >= 2) {
          final alternativeControl = AlternativeSelectionBar(
            labels: labels,
            selected: satIndex,
            onSelected: (int selected) =>
                alternativeController.value = selected,
          );
          if (blocks.first.type == BlockType.Heading) {
            blockWidgets.insert(1, alternativeControl);
          } else {
            blockWidgets.insert(0, alternativeControl);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: blockWidgets,
        );
      },
    );
  }

  List<Widget> _buildBlockWidgets(List<Block> blocks, Block dropCapBlock) {
    return blocks.map<Widget>(
      (block) {
        return BlockWidget(
          block: block,
          dropCap: block == dropCapBlock,
        );
      },
    ).toList();
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
