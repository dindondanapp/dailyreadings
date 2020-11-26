import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

import 'utils.dart';

class ControlsBar extends StatelessWidget {
  final DateTime? date;

  const ControlsBar({Key? key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(SFSymbols.calendar, color: Colors.grey),
            padding: EdgeInsets.zero,
            onPressed: () => {},
          ),
          Text((date ?? DateTime.now()).toLocaleDateString(),
              style: TextStyle(color: Colors.grey)),
          SizedBox(width: 20),
          DecoratedBox(
            child: SizedBox(width: 1, height: 20),
            decoration: BoxDecoration(color: Colors.grey),
          ),
          IconButton(
            icon: Icon(SFSymbols.gear, color: Colors.grey),
            padding: EdgeInsets.zero,
            onPressed: () => {},
          )
        ],
      ),
      margin: EdgeInsets.only(right: 20),
    );
  }
}
