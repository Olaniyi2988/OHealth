//textarea
//textfield
//number
//password

import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:provider/provider.dart';

class DynamicField extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic> value) onValueChanged;
  final GlobalKey key;
  DynamicField({this.config, this.key, this.onValueChanged}) : super(key: key);

  @override
  _DynamicFieldState createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  TextEditingController controller = TextEditingController();
  bool initSet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DynamicFormDataInfo info = DynamicFormDataInfo.of(context);
    if (info != null && info.editData != null && initSet == false) {
      controller = TextEditingController(
          text: info.editData[widget.config['key']].toString());
      initSet = true;
    }

    final InputBorder border = OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: Colors.grey[100]),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.config['prefix'] != null ? 0 : 10),
            bottomLeft:
                Radius.circular(widget.config['prefix'] != null ? 0 : 10),
            topRight: Radius.circular(widget.config['suffix'] != null ? 0 : 10),
            bottomRight:
                Radius.circular(widget.config['suffix'] != null ? 0 : 10)));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.config['label'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.config['label'],
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 7,
                    ),
                  ],
                ),
              )
            : Container(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.config['prefix'] != null
                ? Container(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    height: kToolbarHeight + 3,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(widget.config['prefix'].toString()),
                    ),
                  )
                : Container(),
            Expanded(
                child: TextFormField(
              controller: controller,
              onChanged: (val) {
                Provider.of<AuthProvider>(context, listen: false)
                    .resetInactivityTimer();
                if (info != null) {
                  if (info.columns[widget.config['key']] == "int4") {
                    return widget
                        .onValueChanged({widget.config['key']: int.parse(val)});
                  }
                }
                widget.onValueChanged({widget.config['key']: val});
              },
              keyboardType: info != null
                  ? info.columns[widget.config['key']] == "int4"
                      ? TextInputType.number
                      : TextInputType.text
                  : TextInputType.text,
              style: TextStyle(fontSize: 15),
              enabled: widget.config['disabled'] == null
                  ? true
                  : !widget.config['disabled'],
              decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: border,
                  focusedBorder: border,
                  hintText: widget.config['placeholder'] == null
                      ? ''
                      : widget.config['placeholder'],
                  enabledBorder: border),
              obscureText: widget.config['protected'] == null
                  ? false
                  : widget.config['protected'],
              maxLines: widget.config['type'] == 'textarea'
                  ? widget.config['rows'] == null
                      ? 3
                      : widget.config['rows']
                  : 1,
            )),
            widget.config['suffix'] != null
                ? Container(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    height: kToolbarHeight + 3,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(widget.config['suffix'].toString()),
                    ),
                  )
                : Container(),
          ],
        ),
        widget.config['description'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 7,
                    ),
                    Text(widget.config['description'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey)),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
