import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/extensions.dart';

class AlternativeSelectionBar extends StatelessWidget {
  final List<String> labels;
  final int _selected;
  final void Function(int selected) onSelected;
  int get selected => _selected.sat(lower: 0, upper: labels.length - 1);

  AlternativeSelectionBar(
      {Key key, @required this.labels, selected = 0, @required this.onSelected})
      : this._selected = selected,
        super(key: key) {
    if (labels.length < 2) {
      throw Exception('Provide two or more labels.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _dividedLabels().toList(),
      ),
    );
  }

  Iterable<Widget> _dividedLabels() sync* {
    int index = 0;
    final iterator = labels.iterator;
    if (iterator.moveNext()) {
      yield _buildLabel(index, iterator.current);
      while (iterator.moveNext()) {
        index++;
        yield Builder(
          builder: (context) => Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 30,
            decoration: BoxDecoration(
              border: Border(
                left:
                    BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
            ),
          ),
        );
        yield _buildLabel(index, iterator.current);
      }
    }
  }

  Widget _buildLabel(int index, String label) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: index == selected ? () {} : () => onSelected(index),
        child: Text(
          label ?? '',
          style: index == selected
              ? TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).primaryColor,
                  fontStyle: FontStyle.italic,
                )
              : TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontStyle: FontStyle.italic,
                ),
        ),
      ),
    );
  }
}
