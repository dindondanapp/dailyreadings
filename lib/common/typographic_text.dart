import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that displays a paragrph with drop cap, if possible
class TypographicText extends StatelessWidget {
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
  final double indent;

  /// Automatically higlight special chars such as response "R" and cross
  final bool highlightSpecialChars;

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
  TypographicText({
    Key key,
    @required this.text,
    this.style,
    this.dropCapLines = 0,
    this.textAlign = TextAlign.left,
    this.dropCapMargin = 5,
    this.dropCapStyle = const TextStyle(color: Colors.grey),
    this.indent = 0,
    this.highlightSpecialChars = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final painter = TypographicTextPainter(
          text: text,
          style: DefaultTextStyle.of(context).style.merge(style),
          textAlign: textAlign,
          dropCapLines: dropCapLines,
          dropCapMargin: dropCapMargin,
          dropCapStyle: dropCapStyle,
          indent: indent,
          context: context,
          highlightSpecialChars: highlightSpecialChars,
        )..layout(maxWidth: maxWidth);
        return CustomPaint(
          size: Size(maxWidth, painter.height),
          painter: painter,
        );
      },
    );
  }
}

/// The [CustomPainter] that renders the [TypographicText]
class TypographicTextPainter extends CustomPainter {
  /// The size of the drop cap is computed basing on the first letter. Only
  /// characters that fit within the bound of [_capHeightCapitals] are safe to
  /// add to the drop cap, without any risk of vertical overflow
  static final _safeSecondCharacters = [
    // All regular cap-height capital letters
    ...DropCapPainter.capHeightCapitals,
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
    ...DropCapPainter.capHeightCapitals,
    ...DropCapPainter.descentCapitals,
    ...DropCapPainter.accentCapitals
  ].join().characters;

  // Arguments
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int dropCapLines;
  final double dropCapMargin;
  final TextStyle dropCapStyle;
  final BuildContext context;
  final double indent;
  final bool highlightSpecialChars;

  // Features set at layout time
  bool _didLayout = false;

  DropCapPainter _dropCapPainter;
  final List<DelimitedTextPainter> _delimitedTextPainters = [];
  int get _lines => _delimitedTextPainters.fold<int>(
      0, (previousValue, element) => previousValue + element.lines);

  double get _baseIndent {
    return _lines < dropCapLines && _dropCapPainter != null
        ? _dropCapPainter.width + dropCapMargin
        : 0;
  }

  /// Creates the [CustomPainter] that renders the [TypographicText]
  TypographicTextPainter({
    @required this.context,
    @required this.text,
    @required this.style,
    @required this.textAlign,
    @required this.dropCapLines,
    @required this.dropCapMargin,
    @required this.dropCapStyle,
    @required this.indent,
    @required this.highlightSpecialChars,
  });

  /// Total height of the [TypographicText] to be rendered, only available
  /// after [layout] has been called
  double get height {
    assert(
        _didLayout,
        'The painter\'s height is not available'
        'until layout() has been called at least once.');
    return max(
      _delimitedTextPainters.fold<double>(
          0, (previousValue, element) => previousValue + element.height),
      _dropCapPainter != null ? _dropCapPainter.heightTarget : 0,
    );
  }

  double get _dropCapHeightTarget =>
      style.fontSize * style.height * dropCapLines -
      (style.height - 1) * style.fontSize;

  /// Computes the visual position of all the elements of the
  /// [TypographicText], given the maximum width.
  ///
  /// It must be called at least once before painting or accessing the `height`
  /// property.
  void layout({@required double maxWidth}) {
    final List<List<String>> paragraphs = [];

    final firstWord = text.characters.split(' '.characters).first;
    final String firstLetter =
        firstWord.length >= 1 ? firstWord.characterAt(0).toString() : '';
    final String secondLetter =
        firstWord.length >= 2 ? firstWord.characterAt(1).toString() : '';

    final canHaveDropcap =
        DropCapPainter.capHeightCapitals.contains(firstLetter);

    if (dropCapLines > 0 && canHaveDropcap) {
      // Split drop cap from paragraphs (list of list of words)
      final String dropCapText = (firstWord.length == 2 &&
                  _safeSecondCharacters.contains(secondLetter)) ||
              _specialSecondCharacters.contains(secondLetter)
          ? firstLetter + secondLetter
          : firstLetter;

      _dropCapPainter = DropCapPainter(
          text: dropCapText,
          heightTarget: _dropCapHeightTarget,
          textAlign: textAlign,
          style: style.merge(dropCapStyle));

      paragraphs.addAll(text
          .substring(dropCapText.length)
          .split('\n')
          .map((e) => e.trim().split(' '))
          .toList());
    } else {
      _dropCapPainter = null;

      paragraphs
          .addAll(text.split('\n').map((e) => e.trim().split(' ')).toList());
    }

    // Create delimited text painters
    _delimitedTextPainters.clear();
    for (final words in paragraphs) {
      if (indent > 0) {
        if (_lines != 0) {
          // The first row of the paragraph has indent only if it is not also
          // the first line of the block (1)
          _addDelimitedTextPainterIfNeeded(
              maxWidth: maxWidth, words: words, indent: indent, maxLines: 1);
        }

        // Lines next to the drop cap, if present (2)
        _addDelimitedTextPainterIfNeeded(
            maxWidth: maxWidth,
            words: words,
            indent: 0,
            maxLines: dropCapLines - _lines);

        // Other lines (3)
        _addDelimitedTextPainterIfNeeded(
            maxWidth: maxWidth, words: words, indent: 0);

        // EXAMPLE:
        //
        // |---| Praesent commodo cursus magna,           : 2
        // |   | vel scelerisque nisl consectetur et      : 2
        // |---| tortor pellentesque ullamcorper          : 2
        // mattis ligula justo.                           : 3
        //     Sed posuere consectetur est at             : 1
        // lobortis aenean eu leo quam                    : 3
        // pellentesque ornare sem lacinia quam           : 3
        // venenatis vestibulum.                          : 3
      } else {
        // First line (no indent) (1)
        _addDelimitedTextPainterIfNeeded(
            maxWidth: maxWidth, words: words, indent: 0, maxLines: 1);

        // Indented lines next to the drop cap, if present (2)
        _addDelimitedTextPainterIfNeeded(
            maxWidth: maxWidth,
            words: words,
            indent: indent.abs(),
            maxLines: dropCapLines - _lines);

        // Other intented lines (3)
        _addDelimitedTextPainterIfNeeded(
            maxWidth: maxWidth, words: words, indent: indent.abs());

        // EXAMPLE:
        //
        // |---| Praesent commodo cursus,                : 1
        // |   | vel scelerisque nisl consectetur et     : 1
        // |---|     tortor,                             : 2
        // mattis ligula justo,                          : 1
        // wed posuere consectetur est at lobortis       : 1
        //     aenean eu leo quam.                       : 3
        // Pellentesque ornare sem lacinia,              : 1
        // venenatis vestibulum.                         : 1
      }
    }

    _didLayout = true;
  }

  void _addDelimitedTextPainterIfNeeded(
      {@required List<String> words,
      @required double indent,
      @required double maxWidth,
      int maxLines}) {
    if (words.isNotEmpty && (maxLines == null || maxLines > 0)) {
      _delimitedTextPainters.add(
        DelimitedTextPainter(
          words: words.toList(),
          maxWidth: maxWidth,
          indent: _baseIndent + indent,
          maxLines: maxLines,
          textAlign: textAlign,
          style: style,
          highlightSpecialChars: highlightSpecialChars,
          context: context,
        ),
      );
      words.removeRange(0, _delimitedTextPainters.last.printedWords.length);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(_didLayout, 'You must call layout() at least once before painting.');

    double y = 0;

    for (final delimitedTextPainter in _delimitedTextPainters) {
      delimitedTextPainter.paint(
        canvas,
        size,
        Offset(0, y),
      );
      y += delimitedTextPainter.height;
    }

    if (_dropCapPainter != null) {
      _dropCapPainter.paint(canvas, Offset(0, 0));
    }
  }

  @override
  bool shouldRepaint(TypographicTextPainter oldDelegate) {
    return context != oldDelegate.context;
  }
}

class DropCapPainter {
  //Static values
  /// Capital caracters that fit within baseline and cap height
  static final capHeightCapitals = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'.characters;

  /// Capital caracters with a descender
  static final descentCapitals = 'Q'.characters;

  /// Capital caracters with an accent
  static final accentCapitals = 'ÀÁÈÉÌÍÒÓÙÚ'.characters;

  final double heightTarget;

  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  final TextStyle style;

  double get width => textPainter.width;

  DropCapPainter({
    @required String text,
    @required this.heightTarget,
    @required TextAlign textAlign,
    @required this.style,
  }) {
    // Prepare drop cap painter
    textPainter
      ..text = TextSpan(
        text: text,
        style: style.copyWith(
          height: 1,
          fontFamily: 'Charter',
        ),
      )
      ..layout();

    final firstLetter = text.characters.first;
    final metrics = textPainter.computeLineMetrics().first;

    final baseline = metrics.baseline;
    final ascentCoefficient = accentCapitals.contains(firstLetter) ? 1.3 : 0.9;
    final descentCoefficient = descentCapitals.contains(firstLetter) ? 0.2 : 0;

    final scaleFactor =
        heightTarget / (baseline * (ascentCoefficient + descentCoefficient));

    textPainter
      ..textScaleFactor = scaleFactor
      ..layout();
  }

  void paint(Canvas canvas, Offset offset) {
    textPainter.paint(canvas, offset);
  }
}

class DelimitedTextPainter {
  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  final List<String> words = [];
  final List<String> printedWords = [];
  final double indent;
  final int maxLines;
  final double maxWidth;
  final bool highlightSpecialChars;
  final BuildContext context;

  double get height => lines * style.fontSize * style.height;
  final TextStyle style;
  int get lines => maxLines == null
      ? textPainter.computeLineMetrics().length
      : min(maxLines, textPainter.computeLineMetrics().length); //TODO: optimize

  DelimitedTextPainter({
    this.indent = 0,
    @required List<String> words,
    @required this.maxWidth,
    @required TextAlign textAlign,
    @required this.style,
    this.highlightSpecialChars = true,
    this.maxLines,
    @required this.context,
  })  : assert(maxLines == null || maxLines > 0,
            'maxLines must be either null or a strictly positive number.'),
        assert(words != null && words.isNotEmpty,
            'words cannot be null nor empty'),
        assert(maxWidth != null && maxWidth > style.fontSize * 5,
            'maxWidth must be not null and at least 5 times the font size.') {
    textPainter.textAlign = textAlign;

    int wordIndex = maxLines == null ? words.length - 1 : 0;
    do {
      final rawText = words.sublist(0, wordIndex).join(' ');
      final List<TextSpan> spans = [];
      if (highlightSpecialChars) {
        final highlightRegExp = RegExp(
            "\u211F\.?|\u2123\.?|\u2720|(^|\n| )C: |(^|\n| )A: ",
            caseSensitive: true);
        final fadeRegExp = RegExp("\u2731|\u271D", caseSensitive: true);
        final regExp = RegExp(
            [highlightRegExp.pattern, fadeRegExp.pattern].join('|'),
            caseSensitive: true);
        final matches = regExp.allMatches(rawText);
        int lastIndex = 0;
        matches.forEach((RegExpMatch match) {
          if (match.start > lastIndex) {
            spans
                .add(TextSpan(text: rawText.substring(lastIndex, match.start)));
          }
          if (highlightRegExp.hasMatch(match.group(0))) {
            spans.add(
              TextSpan(
                text: match.group(0),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: match.group(0),
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }
          lastIndex = match.end;
        });
        if (lastIndex < rawText.length) {
          spans.add(TextSpan(text: rawText.substring(lastIndex)));
        }
      } else {
        spans.add(TextSpan(text: rawText));
      }

      textPainter
        ..text = TextSpan(
          children: spans,
          style: style,
        )
        ..layout(maxWidth: maxWidth - indent);
      if (maxLines != null &&
          textPainter.computeLineMetrics().length > maxLines) {
        break;
      }
      wordIndex++;
    } while (wordIndex <= words.length);

    printedWords.addAll(words.sublist(0, max(0, wordIndex - 1)));
  }

  void paint(Canvas canvas, Size size, Offset offset) {
    Rect rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.clipRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          maxWidth,
          height,
        ),
        clipOp: ClipOp.intersect);
    textPainter.paint(canvas, offset.translate(indent, 0));
    canvas.restore();
  }
}
