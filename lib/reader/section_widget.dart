import 'dart:math';

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
    return ValueListenableBuilder<int>(
      valueListenable: alternativeController,
      builder: (BuildContext context, int index, Widget _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildBlockWidgets(index).toList(),
        );
      },
    );
  }

  Iterable<Widget> _buildBlockWidgets(int index) sync* {
    final satIndex =
        index.sat(lower: 0, upper: widget.section.alternatives.length - 1);
    final blocks = widget.section.alternatives[satIndex].blocks;

    final labels =
        widget.globalAlternativeController == null ? getLabels() : null;

    final alternativeSelectionBar = (labels != null && labels.length >= 2)
        ? AlternativeSelectionBar(
            labels: labels,
            selected: satIndex,
            onSelected: (int selected) =>
                alternativeController.value = selected,
          )
        : null;

    // TODO: find a more elegant solution
    bool dropCapAdded = false;
    double previousBlockBottomMargin = 0.0;
    for (int i = 0; i < blocks.length; i++) {
      bool isFirstBlock() => i == 0;
      bool isLastBlock() => i >= blocks.length - 1;
      Block currentBlock() => blocks[i];
      Block nextBlock() => !isLastBlock() ? blocks[i + 1] : null;

      // Render the top margin, taking into account the previous block bottom
      // margin
      if (currentBlock().type != BlockType.Space) {
        final double minimumTopMargin = currentBlock().type == BlockType.Heading
            ? DefaultTextStyle.of(context).style.fontSize * 2
            : 0.0;

        final double topMargin =
            max(minimumTopMargin, previousBlockBottomMargin);

        yield SizedBox(height: topMargin);
      }

      if (currentBlock().type == BlockType.Heading) {
        // Heading rendering
        final isSectionHeading = i == 0;

        if (nextBlock != null && nextBlock().type == BlockType.Reference) {
          // Render the heading and the subsequent reference
          yield Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BlockWidget(block: currentBlock()),
              BlockWidget(block: nextBlock()),
            ],
          );

          // Skip the next block, as in was already rendered
          i++;
        } else {
          // Render just the heading
          yield BlockWidget(block: currentBlock());
        }

        // Render the alternative selection bar after the heading
        if (isSectionHeading && alternativeSelectionBar != null) {
          yield alternativeSelectionBar;
        }
      } else {
        // If the first block is not an heading, render immediately the
        // alternative selection bar
        if (isFirstBlock() && alternativeSelectionBar != null) {
          yield alternativeSelectionBar;
        }

        if (currentBlock().type != BlockType.Space) {
          // Render a generic content block, possibly with drop cap
          final dropCap = canHaveDropCap &&
              !dropCapAdded &&
              currentBlock().type == BlockType.Text;
          dropCapAdded |= dropCap;

          yield BlockWidget(
            block: currentBlock(),
            dropCap: dropCap,
          );
        }
      }

      // Bottom margin
      final bottomMargin = [
        BlockType.Heading,
        BlockType.Reference,
        BlockType.Source,
        BlockType.Space
      ].contains(currentBlock().type)
          ? DefaultTextStyle.of(context).style.fontSize
          : 0.0;

      if (isLastBlock()) {
        yield SizedBox(height: bottomMargin);
      } else {
        // If this is not the last block, the margin will be handled by the next
        // block
        previousBlockBottomMargin = bottomMargin;
      }
    }
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
