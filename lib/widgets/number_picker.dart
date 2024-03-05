import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NumberPicker extends StatefulWidget {
  final String text;
  final dynamic initialValue;
  final bool useDouble;
  final void Function(dynamic number) onChanged;
  NumberPicker(
      {this.text,
      this.initialValue = 0,
      this.onChanged,
      this.useDouble = false});
  @override
  State createState() => NumberPickerState();
}

class NumberPickerState extends State<NumberPicker> {
  double value;
  TextEditingController controller;
  @override
  void initState() {
    // TODO: implement initState
    value = double.parse(widget.initialValue.toString());
    controller = TextEditingController(
        text: widget.useDouble == true
            ? value.toString()
            : value.toString().split('.').first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.text, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(
          height: 7,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey[100])),
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      onChanged: (val) {
                        Provider.of<AuthProvider>(context, listen: false)
                            .resetInactivityTimer();
                        value = double.parse(val);
                        if (widget.onChanged != null) {
                          if (widget.useDouble == true) {
                            widget.onChanged(value);
                          } else {
                            widget.onChanged(value.toInt());
                          }
                        }
                      },
                      style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100]))),
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .resetInactivityTimer();
                        value++;
                        controller.text = widget.useDouble == true
                            ? value.toString()
                            : value.toString().split('.').first;
                        if (widget.onChanged != null) {
                          widget.onChanged(value);
                        }
                      },
                      child: Icon(
                        Icons.keyboard_arrow_up_outlined,
                        size: 25,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .resetInactivityTimer();
                        value--;
                        controller.text = widget.useDouble == true
                            ? value.toString()
                            : value.toString().split('.').first;
                        if (widget.onChanged != null) {
                          widget.onChanged(value);
                        }
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 25,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
