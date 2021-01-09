import 'package:dailyreadings/common/enums.dart';
import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:flutter/material.dart';

/// A widget that displays a single [Block] of text, possibly with a drop cap
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
      if (dropCap && block.dropCapCompatible) {
        return DropCapText(
          block.content.substring(1),
          style: TextStyle(
            fontFamily: 'Charter',
            height: 1.5,
            fontSize: DefaultTextStyle.of(context).style.fontSize,
            color: DefaultTextStyle.of(context).style.color,
          ),
          dropCap: CustomDropCap(
            block.content.substring(0, 1),
            style: TextStyle(
              fontSize: DefaultTextStyle.of(context).style.fontSize,
              height: 1.5,
            ),
            linesNumber: 3,
          ),
          textAlign: TextAlign.justify,
        );
      } else {
        return Text(
          block.content,
          style: TextStyle(
            fontFamily: 'Charter',
            fontWeight:
                block.type == BlockType.Emphasis ? FontWeight.bold : null,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        );
      }
    }
  }
}

// TODO: Implement DropCapText from scratch

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
    return tp.width;
  }

  static double getFontSize(String letter, TextStyle style, int linesNumber) {
    final height = getHeight(letter, style, linesNumber);
    return height * (letter == 'Q' ? 1 : 1.2);
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
              0.0, fontSize * (letter == 'Q' ? 0 : 0.06), 0.0),
          child: Text(
            letter,
            style: TextStyle(
              height: 1,
              fontSize: fontSize,
              color: Colors.grey[500],
              fontFamily: 'Charter',
            ),
          ),
        ),
      ),
    );
  }
}
