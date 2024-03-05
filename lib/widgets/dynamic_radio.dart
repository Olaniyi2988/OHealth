//radio

import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:provider/provider.dart';

class DynamicRadio extends StatefulWidget {
  final Map<String, dynamic> config;
  final GlobalKey<DynamicRadioState> key;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicRadio({this.config, this.key, this.onValueChanged}) : super(key: key);

  @override
  DynamicRadioState createState() => DynamicRadioState();
}

class DynamicRadioState extends State<DynamicRadio> {
  var groupValue;
  @override
  Widget build(BuildContext context) {
    DynamicFormDataInfo info = DynamicFormDataInfo.of(context);
    if (info != null && info.editData != null && groupValue == null) {
      groupValue = info.editData[widget.config['key']];
    }
    List values = widget.config['values'];
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
        ...values.map((e) {
          return Row(
            children: [
              Radio(
                  value: e['value'],
                  groupValue: groupValue,
                  onChanged: (val) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .resetInactivityTimer();
                    setState(() {
                      groupValue = val;
                      widget.onValueChanged({widget.config['key']: groupValue});
                    });
                  }),
              Text(e['label'])
            ],
          );
        }).toList(),
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
