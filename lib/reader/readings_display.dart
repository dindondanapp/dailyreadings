import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:flutter/material.dart';

import '../common/enums.dart';
import '../common/extensions.dart';

class ReadingsDisplay extends StatelessWidget {
  final ReadingsData data;
  const ReadingsDisplay({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).primaryColor, width: 3),
            ),
          ),
          padding: EdgeInsets.only(right: 200, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.date.toLocaleWeekday().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                data.title,
              ),
            ],
          ),
        ),
        ...data.sections.map(
          (section) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: section.alternatives
                .map(
                  (alternative) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: alternative.blocks.map(
                      (block) {
                        const dropCapSections = [
                          SectionType.rLectioPrima,
                          SectionType.rLectioSecunda,
                          SectionType.rEvangelium,
                        ];
                        final dropCap =
                            dropCapSections.contains(section.name) &&
                                block ==
                                    alternative.blocks.firstWhere(
                                        (el) => el.type == BlockType.Text);
                        return BlockWidget(
                          block: block,
                          dropCap: dropCap,
                        );
                      },
                    ).toList(),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;
  final bool dropCap;

  BlockWidget({Key key, @required this.block, this.dropCap = false})
      : super(key: key) {
    if (block.type != BlockType.Text && dropCap) {
      throw Exception('Only text blocks can have drop cap.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (block.type == BlockType.Heading) {
      return Container(
        padding: EdgeInsets.only(
          top: (DefaultTextStyle.of(context).style.fontSize ?? 14) * 2,
          bottom: DefaultTextStyle.of(context).style.fontSize ?? 14,
        ),
        child: Text(
          block.content.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: DefaultTextStyle.of(context).style.fontSize ?? 14,
            fontFamily: 'SF Pro',
          ),
        ),
      );
    } else if (block.type == BlockType.Space) {
      return Text('');
    } else if (block.type == BlockType.Reference) {
      return Text(
        block.content,
        style: TextStyle(
          fontFamily: 'SF Pro',
          height: 1.5,
          color: Theme.of(context).primaryColor,
        ),
      );
    } else {
      if (dropCap) {
        return DropCapText(
          block.content.substring(1),
          style: TextStyle(
            fontFamily: 'Charter',
            height: 1.5,
          ),
          dropCap: CustomDropCap(
            block.content.substring(0, 1),
            style: TextStyle(
              fontSize: DefaultTextStyle.of(context).style.fontSize,
              height: 1.5,
            ),
            linesNumber: 4,
          ),
          textAlign: TextAlign.justify,
        );
      } else {
        return Text(
          block.content,
          style: TextStyle(
            fontFamily: 'Charter',
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        );
      }
    }
  }
}

class CustomDropCap extends DropCap {
  final int linesNumber;
  final TextStyle style;
  final String letter;
  CustomDropCap(
    this.letter, {
    this.linesNumber = 3,
    @required this.style,
  }) : super(
          height: getHeight(letter, style, linesNumber),
          width: getWidth(letter, style, linesNumber),
          child: null,
        );

  static double getHeight(String letter, TextStyle style, int linesNumber) {
    return style.fontSize * style.height * linesNumber;
  }

  static double getWidth(String letter, TextStyle style, int linesNumber) {
    TextStyle painterStyle = TextStyle(
      height: 1,
      fontFamily: 'Charter',
      fontSize: getFontSize(letter, style, linesNumber),
    );
    final tp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: letter, style: painterStyle));
    tp.layout();
    print(tp.width);
    return tp.width;
  }

  static double getFontSize(String letter, TextStyle style, int linesNumber) {
    final height = getHeight(letter, style, linesNumber);
    return height * (letter == 'Q' ? 1 : 1.25);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = getFontSize(letter, style, linesNumber);
    return SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        maxHeight: double.infinity,
        child: Container(
          transform: Matrix4.translationValues(
              0.0, fontSize * (letter == 'Q' ? -0.05 : 0.05), 0.0),
          child: Text(
            letter,
            style: TextStyle(
              height: 1,
              fontSize: fontSize,
              color: Theme.of(context).primaryColor,
              fontFamily: 'Charter',
            ),
          ),
        ),
      ),
    );
  }
}
