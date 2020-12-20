import 'package:flutter/material.dart';

import 'readings_repository.dart';
import 'utils.dart';

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
                    children: alternative.blocks
                        .map(
                          (block) => BlockWidget(block: block),
                        )
                        .toList(),
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

  const BlockWidget({Key key, @required this.block}) : super(key: key);

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
