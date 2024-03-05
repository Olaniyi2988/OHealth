import 'package:flutter/material.dart';
import 'package:kp/widgets/dynamic_form.dart';

class DynamicFormGroup extends StatefulWidget {
  final Map<String, dynamic> config;
  final GlobalKey<DynamicFormGroupState> key;
  final String groupName;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicFormGroup({this.config, this.key, this.onValueChanged, this.groupName})
      : super(key: key);

  @override
  DynamicFormGroupState createState() => DynamicFormGroupState();
}

class DynamicFormGroupState extends State<DynamicFormGroup> {
  List<Widget> children = [];
  Map<String, dynamic> value = {};
  @override
  Widget build(BuildContext context) {
    if (widget.config['components'] == null &&
        widget.config['columns'] == null) {
      return Container();
    }
    if (widget.config['components'] != null) {
      widget.config['components'].forEach((component) {
        Widget temp = getDynamicComponent(component, (value) {
          this.value = {...this.value, ...value};
          if (widget.groupName != null) {
            return widget.onValueChanged({widget.groupName: this.value});
          }
          widget.onValueChanged(this.value);
        });
        if (temp != null) {
          children.add(temp);
        }
      });
    }

    if (widget.config['columns'] != null) {
      widget.config['columns'].forEach((component) {
        Widget temp = getDynamicComponent(component, (value) {
          this.value = {...this.value, ...value};
          if (widget.groupName != null) {
            return widget.onValueChanged({widget.groupName: this.value});
          }
          widget.onValueChanged(this.value);
        });
        if (temp != null) {
          children.add(temp);
        }
      });
    }
    try {
      // rows = splitToChunks(children, 2);
    } catch (err) {}

    return Column(
      children: children.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: e,
        );
      }).toList(),
    );
  }
}
