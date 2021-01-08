import 'package:flutter/material.dart';

import '../common/extensions.dart';

class AlternativeControlWidget extends StatelessWidget {
  final List<String> labels;
  final int _selected;
  final void Function(int selected) onSelected;
  int get selected => _selected.sat(lower: 0, upper: labels.length - 1);

  AlternativeControlWidget(
      {Key key, @required this.labels, selected = 0, @required this.onSelected})
      : this._selected = selected,
        super(key: key) {
    if (labels.length < 2) {
      throw Exception('Provide two or more labels.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _dividedLabels().toList(),
    );
  }

  Iterable<Widget> _dividedLabels() sync* {
    int index = 0;
    labels.iterator.moveNext();
    yield _buildLabel(index, labels.iterator.current);
    while (labels.iterator.moveNext()) {
      index++;
      yield Text(', ');
      yield _buildLabel(index, labels.iterator.current);
    }
  }

  Widget _buildLabel(int index, String label) {
    return TextButton(
      onPressed: index == selected ? () {} : () => onSelected(index),
      child: Text(
        label,
        style: index == selected
            ? TextStyle(
                decoration: TextDecoration.underline,
              )
            : null,
      ),
    );
  }
}
