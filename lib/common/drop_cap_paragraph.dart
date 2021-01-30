import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that displays a paragrph with drop cap, if possible
class DropCapParagraph extends StatelessWidget {
  /// The text of the paragraph
  final String text;

  /// The [TextStyle] of the paragraph
  final TextStyle style;

  /// The text alignment of the paragraph; at this time only left and justify
  /// are supported
  final TextAlign textAlign;

  /// The number of lines the drop cap will extend for
  final int dropCapLines;

  /// The margin on the left of the drop cap
  final double dropCapMargin;

  /// The styling of the drop cap; at this time the font cannot be customized,
  /// and will be forced into 'Charter'
  final TextStyle dropCapStyle;

  /// Creates a paragraph with drop capital, given the `text` of the paragraph.
  ///
  /// The following optional arguments can be provided:
  /// - `style`: the [TextStyle] of the paragraph
  /// - `dropCapLines`: the number of lines the drop cap will extend for
  /// - `textAlign`: the text alignment of the paragraph; at this time only left
  /// and justify are supported
  /// - `dropCapMargin`: the margin on the left of the drop cap
  /// - `dropCapStyle`: the styling of the drop cap; at this time the font
  /// cannot be customized, and will be forced into 'Charter'
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
    if (DropCapParagraphPainter.allowedCharacters
        .contains(text.characters.first)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final painter = DropCapParagraphPainter(
              text: text,
              style: style,
              textAlign: textAlign,
              dropCapLines: dropCapLines,
              dropCapMargin: dropCapMargin,
              dropCapStyle: dropCapStyle,
              context: context)
            ..layout(maxWidth: maxWidth);
          return CustomPaint(
            size: Size(maxWidth, painter.height),
            painter: painter,
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
}

/// The [CustomPainter] that renders the [DropCapParagraph]
class DropCapParagraphPainter extends CustomPainter {
  //Static values
  static final _regularCapCharacters = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'.characters;
  static final _descentCapCharacters = 'Q'.characters;
  static final _accentCapCharacters = 'ÀÁÈÉÌÍÒÓÙÚ'.characters;

  /// A list of allowed characters for the drop cap. Using different a different
  /// characters as the initial character of the paragraph will presumably
  /// result in clipping or overflow
  static final Characters allowedCharacters = [
    ..._regularCapCharacters,
    ..._descentCapCharacters,
    ..._accentCapCharacters
  ].join().characters;

  // Arguments
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int dropCapLines;
  final double dropCapMargin;
  final TextStyle dropCapStyle;
  final BuildContext context;

  // Features set at layout time
  double _dropCapOffset = 0;
  bool _didLayout = false;
  final TextPainter dropCapPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter indentedLinesPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter otherLinesPainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// Creates the [CustomPainter] that renders the [DropCapParagraph]
  DropCapParagraphPainter({
    @required this.context,
    @required this.text,
    @required this.style,
    @required this.textAlign,
    @required this.dropCapLines,
    @required this.dropCapMargin,
    @required this.dropCapStyle,
  });

  /// Total height of the [DropCapParagraph] to be rendered, only available
  /// after layout() has been called
  double get height {
    assert(
        _didLayout,
        'The painter\'s height is not available'
        'until layout() has been called at least once.');
    return max(indentedLinesPainter.height, dropCapHeightTarget) +
        otherLinesPainter.height;
  }

  /// Computes the visual position of all the elements of the
  /// [DropCapParagraph], given the maximum width.
  ///
  /// It must be called at least once before painting or accessing the `height`
  /// property.
  void layout({@required double maxWidth}) {
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

    final metrics = dropCapPainter.computeLineMetrics().first;

    final baseline = metrics.baseline;
    final ascentCoefficient =
        _regularCapCharacters.contains(firstLetter) ? 0.9 : 1.3;
    final descentCoefficient =
        _descentCapCharacters.contains(firstLetter) ? 0.2 : 0;

    final scaleFactor = dropCapHeightTarget /
        (baseline * (ascentCoefficient + descentCoefficient));

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
        ..layout(maxWidth: maxWidth - dropCapPainter.width - dropCapMargin);
    } while (
        !indentedLinesPainter.didExceedMaxLines && wordIndex < words.length);

    while (words[wordIndex - 1] == '\n') wordIndex++;

    final firstLineMetrics = indentedLinesPainter.computeLineMetrics().first;
    print(firstLineMetrics.baseline - firstLineMetrics.ascent / style.height);
    _dropCapOffset = scaleFactor * baseline * (1 - ascentCoefficient) -
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
      ..layout(maxWidth: maxWidth);

    _didLayout = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(_didLayout, 'You must call layout() at least once before painting.');

    dropCapPainter.paint(canvas, Offset(0, -_dropCapOffset));
    indentedLinesPainter.paint(
        canvas, Offset(dropCapPainter.width + dropCapMargin, 0));
    otherLinesPainter.paint(canvas, Offset(0, indentedLinesPainter.height));
  }

  @override
  bool shouldRepaint(DropCapParagraphPainter oldDelegate) {
    return context != oldDelegate.context;
  }

  double get dropCapHeightTarget =>
      style.fontSize * style.height * dropCapLines -
      (style.height - 1) * style.fontSize;
}
