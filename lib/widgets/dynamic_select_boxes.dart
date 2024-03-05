//selectboxes

import 'package:flutter/material.dart';
import 'package:kp/widgets/dynamic_select_box.dart';

class DynamicSelectBoxes extends StatefulWidget {
  final Map<String, dynamic> config;
  final GlobalKey<DynamicSelectBoxesState> key;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicSelectBoxes({this.config, this.key, this.onValueChanged})
      : super(key: key);
  @override
  State createState() => DynamicSelectBoxesState();
}

class DynamicSelectBoxesState extends State<DynamicSelectBoxes> {
  List values;
  List<Widget> boxes = [];
  Map<String, dynamic> childrenData = {};

  @override
  Widget build(BuildContext context) {
    values = widget.config['values'];
    values.forEach((e) {
      boxes.add(Column(
        children: [
          DynamicSelectBox(
            config: {
              'type': 'checkbox',
              'label': e['label'],
              'value': e['value'],
              'key': e['value'],
              'isSelectBoxes': true
            },
            onValueChanged: (value) {
              childrenData.addAll(value);
              widget.onValueChanged(
                  {widget.config['key']: childrenData.values.toList()});
            },
          ),
          SizedBox(
            height: 10,
          )
        ],
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.config['label'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(widget.config['label']),
              )
            : Container(),
        ...boxes,
        widget.config['description'] != null
            ? Padding(
                child: Text(
                  widget.config['description'],
                  style: TextStyle(color: Colors.grey),
                ),
                padding: EdgeInsets.only(left: 15),
              )
            : Container(),
      ],
    );
  }
}
