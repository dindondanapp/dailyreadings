import 'package:dailyreadings/common/entities.dart';
import 'package:dailyreadings/common/typographic_text.dart';
import 'package:flutter/material.dart';

/// A widget that displays a single [Block] of text, possibly with a drop cap
class BlockWidget extends StatelessWidget {
  final Block block;

  BlockWidget({Key key, @required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (block.type == BlockType.Heading) {
      return Text(
        block.content.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: DefaultTextStyle.of(context).style.fontSize ?? 14,
          fontFamily: 'SF Pro',
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
    } else if (block.type == BlockType.Source) {
      return TypographicText(
        text: block.content,
        style: TextStyle(
          fontFamily: 'Charter',
          height: 1.5,
        ),
        dropCapLines: 0,
      );
    } else if (block.type == BlockType.Emphasis) {
      return TypographicText(
        text: block.content,
        style: TextStyle(
          fontFamily: 'Charter',
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        dropCapLines: 0,
      );
    } else if (block.type == BlockType.Note) {
      return TypographicText(
        text: block.content,
        style: TextStyle(
          fontFamily: 'Charter',
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
        dropCapLines: 0,
      );
    } else {
      return TypographicText(
        text: block.content,
        dropCapLines: block.type == BlockType.Passage ? 3 : 0,
        style: TextStyle(
          fontFamily: 'Charter',
          height: 1.5,
          color: DefaultTextStyle.of(context).style.color,
        ),
        dropCapStyle: TextStyle(
          color: Colors.grey,
        ),
        indent: block.type == BlockType.Passage
            ? 20.0
            : block.type == BlockType.Poetry
                ? -20.0
                : 0.0,
        textAlign: TextAlign.justify,
      );
    }
  }
}
