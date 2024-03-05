//checkbox
//radio

import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:provider/provider.dart';

class DynamicSelectBox extends StatefulWidget {
  final Map config;
  final GlobalKey<DynamicSelectBoxState> key;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicSelectBox({this.config, this.key, this.onValueChanged})
      : super(key: key);
  @override
  State createState() => DynamicSelectBoxState();
}

class DynamicSelectBoxState extends State<DynamicSelectBox> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    DynamicFormDataInfo info = DynamicFormDataInfo.of(context);
    if (info != null && info.editData != null) {
      if (widget.config['isSelectBoxes'] == true &&
          widget.config['value'] == info.editData[widget.config['key']]) {
        selected = true;
      } else if (info.editData[widget.config['key']] != null) {
        selected = true;
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.config['type'] == 'checkbox' ||
                    widget.config['type'] == 'radio'
                ? Checkbox(
                    value: selected,
                    onChanged: widget.config['disabled'] == true
                        ? null
                        : (val) {
                            Provider.of<AuthProvider>(context, listen: false)
                                .resetInactivityTimer();
                            setState(() {
                              selected = val;
                              widget.onValueChanged({
                                widget.config['key']:
                                    widget.config['isSelectBoxes'] == true
                                        ? widget.config['value']
                                        : widget.config['value'] != null
                                            ? widget.config['value']
                                            : selected
                              });
                            });
                          },
                  )
                : Container(),
            Expanded(
                child: Text(widget.config['label'] == null
                    ? ''
                    : widget.config['label']))
          ],
        ),
        widget.config['description'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  widget.config['description'],
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Container()
      ],
    );
  }
}
