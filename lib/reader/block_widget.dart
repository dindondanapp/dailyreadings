import 'package:dailyreadings/common/drop_cap_paragraph.dart';
import 'package:dailyreadings/common/entities.dart';
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
        return DropCapParagraph(
          text: block.content,
          dropCapLines: 3,
          style: TextStyle(
            fontFamily: 'Charter',
            height: 1.5,
            fontSize: DefaultTextStyle.of(context).style.fontSize,
            color: DefaultTextStyle.of(context).style.color,
          ),
          dropCapStyle: TextStyle(
            color: Colors.grey,
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
