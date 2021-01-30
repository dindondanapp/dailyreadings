import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class DropCapParagraphPainter extends CustomPainter {
  final DropCapParagraphPaintersData paintersData;

  DropCapParagraphPainter({@required this.paintersData});

  @override
  void paint(Canvas canvas, Size size) {
    paintersData.paint(canvas);
  }

  @override
  bool shouldRepaint(DropCapParagraphPainter oldDelegate) {
    return false;
  }
}

class DropCapParagraph extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int dropCapLines;
  final double dropCapMargin;
  final TextStyle dropCapStyle;

  static final regularCapCharacters = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'.characters;
  static final descentCapCharacters = 'Q'.characters;
  static final accentCapCharacters = 'ÀÁÈÉÌÍÒÓÙÚ'.characters;

  static final Characters allowedCharacters = [
    ...regularCapCharacters,
    ...descentCapCharacters,
    ...accentCapCharacters
  ].join().characters;

  DropCapParagraph({
    Key key,
    @required this.text,
    this.style,
    this.dropCapLines = 3,
    this.textAlign = TextAlign.left,
    this.dropCapMargin = 5,
    this.dropCapStyle = const TextStyle(color: Colors.grey),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowedCharacters.contains(text.characters.first)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final paintersData = generatePainters(
              DefaultTextStyle.of(context).style.merge(style), width);

          return CustomPaint(
            size: Size(width, paintersData.height),
            painter: DropCapParagraphPainter(paintersData: paintersData),
          );
        },
      );
    } else {
      print(text.characters.first);
      return Text(
        text,
        style: style,
        textAlign: textAlign,
      );
    }
  }

  DropCapParagraphPaintersData generatePainters(TextStyle style, double width) {
    final TextPainter dropCapPainter =
        TextPainter(textDirection: TextDirection.ltr);
    final TextPainter indentedLinesPainter =
        TextPainter(textDirection: TextDirection.ltr);
    final TextPainter otherLinesPainter =
        TextPainter(textDirection: TextDirection.ltr);

    final firstLetter = text.characters.first;
    dropCapPainter
      ..text = TextSpan(
        text: firstLetter,
        style: dropCapStyle.copyWith(
          height: 1,
          fontFamily: 'Charter',
        ),
      )
      ..layout();

    final words = text.substring(1).replaceAll('\n', ' \n ').split(' ');
    int wordIndex = 0;

    final heightTarget = style.fontSize * style.height * dropCapLines -
        (style.height - 1) * style.fontSize;
    final metrics = dropCapPainter.computeLineMetrics().first;

    final baseLine = metrics.baseline;
    final ascentCoefficient =
        regularCapCharacters.contains(firstLetter) ? 0.9 : 1.3;
    final descentCoefficient =
        descentCapCharacters.contains(firstLetter) ? 0.2 : 0;

    final scaleFactor =
        heightTarget / (baseLine * (ascentCoefficient + descentCoefficient));

    dropCapPainter
      ..textScaleFactor = scaleFactor
      ..layout();

    indentedLinesPainter..maxLines = dropCapLines;

    do {
      wordIndex++;
      indentedLinesPainter
        ..text = TextSpan(
          text: words
              .sublist(0, wordIndex)
              .join(' ')
              .replaceAll(' \n', '\n')
              .replaceAll('\n ', '\n'),
          style: style,
        )
        ..textAlign = textAlign
        ..layout(maxWidth: width - dropCapPainter.width - dropCapMargin);
    } while (
        !indentedLinesPainter.didExceedMaxLines && wordIndex < words.length);

    while (words[wordIndex - 1] == '\n') wordIndex++;

    final firstLineMetrics = indentedLinesPainter.computeLineMetrics().first;
    print(firstLineMetrics.baseline - firstLineMetrics.ascent / style.height);
    final dropCapOffset = scaleFactor * baseLine * (1 - ascentCoefficient) -
        (firstLineMetrics.baseline - firstLineMetrics.ascent / style.height);

    otherLinesPainter
      ..text = TextSpan(
        text: wordIndex >= words.length
            ? ''
            : words
                .sublist(wordIndex - 1)
                .join(' ')
                .replaceAll(' \n', '\n')
                .replaceAll('\n ', '\n'),
        style: style,
      )
      ..textAlign = textAlign
      ..layout(maxWidth: width);

    return DropCapParagraphPaintersData(
      dropCapOffset: dropCapOffset,
      dropCapPainter: dropCapPainter,
      dropCapMargin: dropCapMargin,
      indentedLinesPainter: indentedLinesPainter,
      otherLinesPainter: otherLinesPainter,
      dropCapHeightTarget: heightTarget,
    );
  }
}

class DropCapParagraphPaintersData {
  final TextPainter dropCapPainter;
  final TextPainter indentedLinesPainter;
  final TextPainter otherLinesPainter;
  final double dropCapOffset;
  final double dropCapHeightTarget;
  final double dropCapMargin;

  double get height =>
      max(indentedLinesPainter.height, dropCapHeightTarget) +
      otherLinesPainter.height;

  DropCapParagraphPaintersData({
    @required this.dropCapPainter,
    @required this.indentedLinesPainter,
    @required this.otherLinesPainter,
    @required this.dropCapOffset,
    @required this.dropCapHeightTarget,
    @required this.dropCapMargin,
  });

  void paint(Canvas canvas) {
    dropCapPainter.paint(canvas, Offset(0, -dropCapOffset));
    indentedLinesPainter.paint(
        canvas, Offset(dropCapPainter.width + dropCapMargin, 0));
    otherLinesPainter.paint(canvas, Offset(0, indentedLinesPainter.height));
  }
}
