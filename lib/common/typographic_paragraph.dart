import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that displays a paragrph with drop cap, if possible
class TypographicParagraph extends StatelessWidget {
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

  /// Add indentation on line breaks
  final bool indent;

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
  TypographicParagraph({
    Key key,
    @required this.text,
    this.style,
    this.dropCapLines = 3,
    this.textAlign = TextAlign.left,
    this.dropCapMargin = 5,
    this.dropCapStyle = const TextStyle(color: Colors.grey),
    this.indent = true,
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
            style: DefaultTextStyle.of(context).style.merge(style),
            textAlign: textAlign,
            dropCapLines: dropCapLines,
            dropCapMargin: dropCapMargin,
            dropCapStyle: dropCapStyle,
            indent: indent,
            context: context,
          )..layout(maxWidth: maxWidth);
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

/// The [CustomPainter] that renders the [TypographicParagraph]
class DropCapParagraphPainter extends CustomPainter {
  //Static values
  /// Capital caracters that fit within baseline and cap height
  static final _capHeightCapitals = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'.characters;

  /// Capital caracters with a descender
  static final _descentCapitals = 'Q'.characters;

  /// Capital caracters with an accent
  static final _accentCapitals = 'ÀÁÈÉÌÍÒÓÙÚ'.characters;

  /// The size of the drop cap is computed basing on the first letter. Only
  /// characters that fit within the bound of [_capHeightCapitals] are safe to
  /// add to the drop cap, without any risk of vertical overflow
  static final _safeSecondCharacters = [
    // All regular cap-height capital letters
    ..._capHeightCapitals,
    // All lower case letters without a descender
    ...'abcdefhiklmnorstuvwz'.characters,
  ].join().characters;

  /// Special characters that can be added to the drop cap even if there is no
  /// space after
  static final _specialSecondCharacters = '.,\':-?'.characters;

  /// A list of allowed characters for the drop cap. Using different a different
  /// characters as the initial character of the paragraph will presumably
  /// result in clipping or overflow
  static final Characters allowedCharacters = [
    ..._capHeightCapitals,
    ..._descentCapitals,
    ..._accentCapitals
  ].join().characters;

  // Arguments
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int dropCapLines;
  final double dropCapMargin;
  final TextStyle dropCapStyle;
  final BuildContext context;
  final bool indent;

  // Features set at layout time
  double _dropCapOffset = 0;
  bool _didLayout = false;
  final TextPainter dropCapPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter dropCapLinesPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter otherLinesPainter =
      TextPainter(textDirection: TextDirection.ltr);

  /// Creates the [CustomPainter] that renders the [TypographicParagraph]
  DropCapParagraphPainter({
    @required this.context,
    @required this.text,
    @required this.style,
    @required this.textAlign,
    @required this.dropCapLines,
    @required this.dropCapMargin,
    @required this.dropCapStyle,
    @required this.indent,
  });

  /// Total height of the [TypographicParagraph] to be rendered, only available
  /// after layout() has been called
  double get height {
    assert(
        _didLayout,
        'The painter\'s height is not available'
        'until layout() has been called at least once.');
    return style.fontSize * style.height * dropCapLines +
        otherLinesPainter.height;
  }

  double get _dropCapHeightTarget =>
      style.fontSize * style.height * dropCapLines -
      (style.height - 1) * style.fontSize;

  /// Computes the visual position of all the elements of the
  /// [TypographicParagraph], given the maximum width.
  ///
  /// It must be called at least once before painting or accessing the `height`
  /// property.
  void layout({@required double maxWidth}) {
    final firstWord = text.characters.split(' '.characters).first;
    final String firstLetter =
        firstWord.length >= 1 ? firstWord.characterAt(0).toString() : '';
    final String secondLetter =
        firstWord.length >= 2 ? firstWord.characterAt(1).toString() : '';
    final String dropCapText = (firstWord.length == 2 &&
                _safeSecondCharacters.contains(secondLetter)) ||
            _specialSecondCharacters.contains(secondLetter)
        ? '$firstLetter$secondLetter'
        : firstLetter;

    final prepareParagraphMainText = (string) => string
        .split('\n')
        .map((e) => e.trim())
        .toList()
        .join('\n' + (indent ? (' ' * 6) : ''));

    dropCapPainter
      ..text = TextSpan(
        text: dropCapText,
        style: dropCapStyle.copyWith(
          height: 1,
          fontFamily: 'Charter',
        ),
      )
      ..layout();

    final words = text
        .substring(dropCapText.length)
        .trim()
        .replaceAll('\n', ' \n ')
        .split(' ');

    int wordIndex = 0;

    final metrics = dropCapPainter.computeLineMetrics().first;

    final baseline = metrics.baseline;
    final ascentCoefficient = _accentCapitals.contains(firstLetter) ? 1.3 : 0.9;
    final descentCoefficient = _descentCapitals.contains(firstLetter) ? 0.2 : 0;

    final scaleFactor = _dropCapHeightTarget /
        (baseline * (ascentCoefficient + descentCoefficient));

    dropCapPainter
      ..textScaleFactor = scaleFactor
      ..layout();

    dropCapLinesPainter
      ..maxLines = dropCapLines + 1
      ..textAlign = textAlign;

    do {
      wordIndex++;
      dropCapLinesPainter
        ..text = TextSpan(
          text: prepareParagraphMainText(words.sublist(0, wordIndex).join(' ')),
          style: style,
        )
        ..layout(maxWidth: maxWidth - dropCapPainter.width - dropCapMargin);
    } while (dropCapLinesPainter.computeLineMetrics().length <= dropCapLines &&
        wordIndex < words.length);

    while (words[wordIndex - 1] == '\n') wordIndex++;

    final firstLineMetrics = dropCapLinesPainter.computeLineMetrics().first;
    print(firstLineMetrics.baseline - firstLineMetrics.ascent / style.height);
    _dropCapOffset = scaleFactor * baseline * (1 - ascentCoefficient) -
        (firstLineMetrics.baseline - firstLineMetrics.ascent / style.height);

    otherLinesPainter
      ..text = TextSpan(
        text: wordIndex >= words.length
            ? ''
            : prepareParagraphMainText(words.sublist(wordIndex - 1).join(' ')),
        style: style,
      )
      ..textAlign = textAlign
      ..layout(maxWidth: maxWidth);

    _didLayout = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(_didLayout, 'You must call layout() at least once before painting.');

    otherLinesPainter.paint(canvas,
        Offset(0, dropCapLinesPainter.height - style.height * style.fontSize));

    canvas.clipRect(Rect.fromLTWH(
        0, 0, size.width, style.height * style.fontSize * dropCapLines));
    dropCapPainter.paint(canvas, Offset(0, -_dropCapOffset));
    dropCapLinesPainter.paint(
        canvas, Offset(dropCapPainter.width + dropCapMargin, 0));
  }

  @override
  bool shouldRepaint(DropCapParagraphPainter oldDelegate) {
    return context != oldDelegate.context;
  }
}
